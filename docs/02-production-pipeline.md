# 제작 파이프라인

모든 파라미터는 `external/Applio/core.py` 및 `external/Applio/rvc/infer/pipeline.py` 원문에서 확인한 값이다 (Applio `3b8c321`, 2026-07-29).

## 0단계 — 방향 검증 (학습 0분, 반나절)

RVC 모델 학습에 들어가기 전에 **캐릭터 음색 방향이 맞는지** 먼저 확인한다. 여기서 틀리면 데이터셋 확보 비용이 날아간다.

```bash
# Chatterbox — MIT, 학습 불필요
pip install chatterbox-tts
```

```python
import torchaudio as ta
from chatterbox.vc import ChatterboxVC

vc = ChatterboxVC.from_pretrained(device="cuda")
wav = vc.generate("male_take_01.wav", target_voice_path="target_girl_ref.wav")
ta.save("out_01.wav", wav, vc.sr)
```

- 참조 음성은 **앞 10초만 사용**된다(`DEC_COND_LEN = 10 * S3GEN_SR`). 가장 대표적인 10초를 잘라서 넣을 것.
- 출력에는 Perth 워터마크가 삽입된다. 방향 검증용이므로 이 단계에서는 무관하다.
- 후보 여성 참조음성 3~5개 × 남성 테이크 3개를 교차 변환해 캐릭터에 맞는 음역을 고른다.

## 1단계 — 타겟 여성 음성 데이터셋

| 항목 | 기준 |
|---|---|
| 분량 | 최소 10분, 권장 **20~40분** |
| 화자 | **단일 화자만** (섞으면 음색이 평균화돼 무너진다) |
| 포맷 | WAV, 48kHz/24bit, 모노 |
| 환경 | BGM·리버브·룸 반사 없음. 노이즈 플로어 낮게 |
| 내용 | 평상 대사 / 감정 대사 / 작은 목소리 / 외침 **균등 분포** |
| 한국어 | 게임에 실제 나올 발음·감탄사·받침 조합 포함 |
| 권리 | **AI 학습 + 음성 변환 + 상업적 이용**을 명시한 서면 계약 → [04-licensing.md](04-licensing.md) |

**외침(shout)을 빼놓지 말 것.** 탑다운 슈터는 전투 대사 비중이 높은데, 조용한 낭독만으로 학습한 모델은 외침 대사에서 파형이 깨진다.

> ⚠️ 인터넷에 배포되는 "애니 캐릭터 RVC 모델"은 게임 출시에 쓸 수 없다. 소프트웨어가 MIT라도 **가중치와 학습 데이터의 권리는 별개**다.

## 2단계 — Applio RVC 모델 학습

```bash
git clone https://github.com/IAHispano/Applio
cd Applio && ./run-install.bat        # Windows
```

```bash
python core.py preprocess --model_name kawaii_v1 \
  --dataset_path ./dataset/target_girl --sample_rate 48000

python core.py extract --model_name kawaii_v1 --sample_rate 48000 \
  --f0_method rmvpe --embedder_model korean-hubert-base

python core.py train --model_name kawaii_v1 --sample_rate 48000 \
  --total_epoch 300 --batch_size 8 --vocoder "RefineGAN"

python core.py index --model_name kawaii_v1
```

| 인자 | 확인된 선택지 | 이 프로젝트 |
|---|---|---|
| `--sample_rate` | `32000 / 40000 / 48000` | **48000** (게임 오디오 마스터) |
| `--vocoder` | `HiFi-GAN / MRF HiFi-GAN / RefineGAN` | **RefineGAN** 우선 시험, 불안정하면 HiFi-GAN |
| `--embedder_model` | `contentvec / spin / spin-v2 / chinese-hubert-base / japanese-hubert-base / korean-hubert-base / custom` | **korean-hubert-base** |
| `--f0_method` | `crepe / crepe-tiny / rmvpe / fcpe / hybrid[...]` | **rmvpe** |

**추출과 추론의 `--embedder_model`은 반드시 일치해야 한다.** 학습을 `korean-hubert-base`로 하고 추론을 기본값 `contentvec`으로 돌리면 발음이 뭉개진다.

RTX 4080 랩톱이면 20~40분 데이터셋 × 300 epoch는 수 시간 규모다. 과적합 방지를 위해 중간 체크포인트를 남기고 청감 비교할 것.

## 3단계 — 배치 변환

```bash
python core.py batch_infer \
  --input_folder  ./raw/male_takes \
  --output_folder ./out/kawaii \
  --pth_path   ./logs/kawaii_v1/kawaii_v1.pth \
  --index_path ./logs/kawaii_v1/added_kawaii_v1.index \
  --embedder_model korean-hubert-base \
  --f0_method rmvpe \
  --proposed_pitch True \
  --proposed_pitch_threshold 255 \
  --pitch 0 \
  --index_rate 0.5 \
  --protect 0.33 \
  --volume_envelope 1 \
  --formant_shifting True \
  --formant_qfrency 1.0 \
  --formant_timbre 1.0 \
  --export_format WAV
```

`scripts/convert_batch.sh` 로 래핑돼 있다.

### 파라미터 해설 (원문 확인 기준)

| 인자 | 기본값 | 권장 | 근거 |
|---|---|---|---|
| `--proposed_pitch` | `False` | **True** | 클립별 `12*log2(255/median_f0)` 자동 산출, ±12 클램프 |
| `--proposed_pitch_threshold` | **155.0 (남성)** | **255** | 코드 주석: `155.0 for male, 255.0 for female`. 기본값 방치 금지 |
| `--pitch` | `0` | **0** | 자동 피치와 **합산**됨(`pitch + up_key`). 같이 +12 주면 이중 시프트 |
| `--index_rate` | `0.3` | 0.4~0.6 | 높으면 타겟 음색↑ 아티팩트↑. 대사별로 다르면 0.3에서 올려가며 조정 |
| `--protect` | `0.33` | 0.33 | 자음·호흡 보호. 0.5가 최대 보호 |
| `--f0_method` | `rmvpe` | rmvpe | 외침에서 불안정하면 `hybrid[rmvpe+fcpe]` 시험 |
| `--formant_shifting` | `False` | **True** | 성도 길이 보정 — "여성 음색인데 남자 같다"의 실제 해법 |
| `--clean_audio` | `False` | False | 게임 오디오는 DAW에서 일괄 처리하는 편이 낫다 |
| `--export_format` | `WAV` | WAV | 무손실 유지. 압축은 언리얼이 담당 |

### 함정 3개 (전부 소스에서 확인)

1. **`--proposed_pitch False`를 넘기면 켜진다.** `type=bool`로 선언돼 있어 `bool("False") == True`. 다른 플래그(`--clean_audio` 등)는 `strtobool`을 쓰는데 이 인자만 다르다. **끄려면 인자를 생략**할 것.
2. **`--proposed_pitch_threshold` 기본값이 남성용 155.0**이다.
3. **자동 피치는 ±12로 클램프**된다(`limit = 12`). 성우가 극도로 낮게 발성하면 상한에 걸려 목표 255Hz에 못 미친다. 이때는 `--pitch`로 +1~2를 추가하거나, 성우에게 흉성을 줄여 달라고 요청하는 편이 낫다.

## 4단계 — 파일럿 A/B 검증 (본 작업 전 필수)

전체 대사를 돌리기 전에 **대표 20개 대사**로 격자 탐색한다. 이걸 건너뛰면 수백 파일을 다시 돌리게 된다.

대표 대사 구성:
- 평상 대사 5 / 감정 고조 5 / **외침 5** / 속삭임·부상 신음 5

비교할 축 (한 번에 하나씩만 변경):

| 실험 | 변수 |
|---|---|
| A | `index_rate` 0.3 / 0.5 / 0.7 |
| B | `formant_shifting` off / on(qfrency·timbre 1.0) / on(조정값) |
| C | `f0_method` rmvpe / hybrid[rmvpe+fcpe] |
| D | `embedder_model` contentvec vs korean-hubert-base (한국어 이득 실측) |
| E | 자동 피치 vs 고정 `--pitch 12` |

**청감 평가 항목:** ① 여고생으로 들리는가 ② 한국어 발음이 뭉개지지 않는가(특히 받침·경음) ③ 외침에서 파형이 깨지지 않는가 ④ 원본 감정이 남아 있는가 ⑤ 대사 간 음색이 일관되는가.

⑤가 특히 중요하다. 게임에서는 같은 캐릭터 대사가 연속 재생되므로 파일 간 음색 흔들림이 단발 품질보다 더 눈에 띈다.

## 5단계 — 후처리 및 납품

1. **디에서** — 피치를 올리면 치찰음(ㅅ/ㅊ/ㅆ)이 과장된다. 남성→여성 변환에서 거의 항상 필요하다.
2. **노이즈·아티팩트 정리** — 필요 시 `resemble-enhance`(MIT) 또는 `DeepFilterNet`
3. **라우드니스 정규화** — 게임 대사는 파일별 편차가 치명적이다. 목표를 정해 일괄 적용:
   ```bash
   ffmpeg -i in.wav -af loudnorm=I=-18:TP=-1.5:LRA=7 -ar 48000 -c:a pcm_s24le out.wav
   ```
   전투 대사는 BGM·총성에 묻히므로 내레이션보다 타이트하게 잡는다.
4. **무음 트림** — 앞뒤 무음이 남으면 탑다운 슈터의 반응 대사가 늦게 들린다.
5. 파일명 규칙 유지 → [05-unreal-integration.md](05-unreal-integration.md)

## 실시간 모니터링 (선택)

```
성우 마이크 → w-okada VCClient (RVC 모델 로드) → 헤드폰
```
성우가 여성 음색으로 변환된 자기 목소리를 들으며 연기를 조정할 수 있다. MIT 라이선스, Windows CUDA 에디션 사용.
**납품물은 실시간 출력이 아니라 오프라인 배치 변환본을 쓴다** — 실시간은 버퍼·드롭·노이즈 영향을 받는다.

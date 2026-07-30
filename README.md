<div align="center">

<h1>KawaiiVoice</h1>

**30세 남성 성우의 연기를 미소녀 여고생 음색으로.**<br>
언리얼 엔진 탑다운 슈터 게임의 한국어 더빙 파이프라인 연구<br><br>

[![License](https://img.shields.io/badge/LICENSE-MIT-green.svg?style=for-the-badge&logo=opensourceinitiative)](./LICENSE)
[![Stars](https://img.shields.io/github/stars/Chang-Jin-Lee/KawaiiVoice?style=for-the-badge&logo=github)](https://github.com/Chang-Jin-Lee/KawaiiVoice/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/Chang-Jin-Lee/KawaiiVoice?style=for-the-badge&logo=git&logoColor=white)](https://github.com/Chang-Jin-Lee/KawaiiVoice/commits/main)
[![Unreal Engine](https://img.shields.io/badge/Unreal_Engine-black?style=for-the-badge&logo=unrealengine)](https://www.unrealengine.com)

[**📊 조사 보고서**](./docs/01-research-report.md)
•
[**⚙️ 제작 파이프라인**](./docs/02-production-pipeline.md)
•
[**🎙️ 음성 디렉션**](./docs/03-voice-direction.md)
•
[**⚖️ 라이선스 체크리스트**](./docs/04-licensing.md)
•
[**🎮 언리얼 통합**](./docs/05-unreal-integration.md)

**한국어** | [**English**](./docs/README.en.md)

</div>

---

> [!NOTE]
> 이 저장소는 실행 가능한 도구가 아니라 **검증된 기술 선택 근거**를 담는다.
> 모든 별 수·라이선스·아카이브 여부는 GitHub API로 직접 조회했고, 라이선스 조항과
> 추론 파라미터는 실제 클론한 소스에서 판독했다. 조사 기준일 **2026-07-30**.

## 결론

| 용도 | 선택 | 라이선스 | 근거 |
|---|---|---|---|
| **게임 최종 더빙 (본선)** | [**Applio**](https://github.com/IAHispano/Applio) | MIT | `korean-hubert-base` 임베더 · 포먼트 시프팅 · 클립별 자동 피치 |
| **무학습 즉시 테스트** | [**Chatterbox**](https://github.com/resemble-ai/chatterbox) `ChatterboxVC` | MIT (코드+가중치) | 학습 0분, 참조음성만으로 변환. 상업적 사용 최안전 |
| **녹음 중 실시간 모니터링** | [**w-okada VCClient**](https://github.com/w-okada/voice-changer) | MIT | 성우가 결과를 들으며 연기 조정 |
| **대사 재합성이 허용될 때** | [**GPT-SoVITS**](https://github.com/RVC-Boss/GPT-SoVITS) | MIT | 60k★, 한국어 지원, 이 분야 최대 활성 저장소 |

### 왜 RVC가 축인가

| 계열 | 입력 | 성우 테이크 보존 | 판정 |
|---|---|---|---|
| **RVC (Applio)** | 오디오 | **높음** — F0 곡선을 명시적으로 추출·시프트 | ✅ **본선** |
| Chatterbox VC | 오디오 | 중간 — 의미 토큰 경유로 미세 억양 일부 손실 | ⚠️ 프로토타입 |
| TTS (GPT-SoVITS, IndexTTS2, CosyVoice) | **텍스트** | **없음** — 대사를 새로 생성 | 대안 경로 |

남성 성우를 섭외하는 이유 자체가 **그 테이크를 쓰기 위한 것**이므로, 텍스트에서 다시 만드는 TTS는 목적과 상충한다. 탑다운 슈터의 짧은 전투 대사("뒤에!", "재장전!")는 타이밍이 곧 게임 피드백이라 특히 그렇다.

## 주요 발견

<details open>
<summary><b>1. Applio를 골라야 하는 이유는 GUI가 아니다</b></summary><br>

`core.py`를 판독한 결과, 바닐라 RVC에 없는 기능 3개가 이 프로젝트의 문제를 정확히 겨냥한다.

- **`--embedder_model korean-hubert-base`** — 한국어 게임에 결정적. 바닐라 RVC는 영어 중심 `contentvec`뿐이다. **기본값이 `contentvec`이라 반드시 명시해야 한다.**
- **포먼트 시프팅** (`--formant_shifting/qfrency/timbre`) — 성별 인지의 상당 부분은 F0가 아니라 성도 길이 = 포먼트 위치에서 온다. 피치만 올리면 "빠르게 감은 남성 목소리"가 된다.
- **클립별 자동 피치** — 아래 3번
</details>

<details open>
<summary><b>2. Chatterbox가 Seed-VC 자리를 대체한다 — MIT로</b></summary><br>

`src/chatterbox/vc.py`에 TTS와 별개로 **실제 음성 변환 클래스**가 있다.

```python
class ChatterboxVC:
    def set_target_voice(self, wav_fpath): ...
    def generate(self, audio, target_voice_path=None): ...
```

코드와 **가중치 모두 MIT**라 상업 게임에 가장 안전하다. 단 소스에서 확인한 제약 3개 — 모든 출력에 Perth 워터마크 삽입, 참조음성 **앞 10초만** 사용(`DEC_COND_LEN = 10 * S3GEN_SR`), S3 *의미 토큰* 경유라 **RVC보다 연기 보존력이 낮다.**
</details>

<details open>
<summary><b>3. 고정 피치 오프셋은 배치 작업에서 위험하다</b></summary><br>

성우 중심 피치는 테이크마다 달라진다(외침 vs 속삭임). 고정 +12는 외침에서 과보정돼 삑사리가 난다. `rvc/infer/pipeline.py`:

```python
limit = 12
up_key = clamp(round(12 * np.log2(proposed_pitch_threshold / median_f0)), ±limit)
f0 *= pow(2, (pitch + up_key) / 12)
```

**함정 3개 (전부 소스 확인):**
1. `--pitch`가 자동값에 **합산**된다 → 같이 `+12`를 주면 이중 시프트
2. `--proposed_pitch_threshold` **기본값이 155.0(남성)** → 여성은 `255` 명시 필수
3. `--proposed_pitch`만 `type=bool`이라 **`False`를 넘기면 켜진다** (`bool("False") == True`)
</details>

<details open>
<summary><b>4. ⚠️ fish-speech는 상업적 사용 금지다</b></summary><br>

여러 "2026 최고의 오픈소스 더빙 모델" 블로그가 지금도 최상위로 추천하지만, LICENSE 원문(**2026-03-07 개정**)은 `FISH AUDIO RESEARCH LICENSE`다.

> "Any Commercial use of the Materials **requires a separate license** from Fish Audio."
> Commercial Purpose에 *"any use in connection with a product or service for which You charge a fee or generate revenue, **whether directly or indirectly**"* 포함

유료 게임뿐 아니라 광고·인앱결제 등 **간접 수익까지 포함**된다. GitHub 배지는 `NOASSERTION`으로만 뜨므로 **배지를 믿지 말고 LICENSE 원문을 읽어야 한다.**
</details>

<details>
<summary><b>5. Seed-VC는 아카이브됐다 / Applio는 유지보수 모드다</b></summary><br>

- `Plachtaa/seed-vc` — **아카이브**, 최종 푸시 2025-04-20. 저자의 저장소(`VALL-E-X`, `VITS-fast-fine-tuning`, `FAcodec` 등)가 **전부 아카이브**됐고, 유지되는 실시간 포크는 존재하지 않는다.
- `IAHispano/Applio` — README 공지: *"Applio will no longer receive frequent updates ... focus mainly on security patches."* **이미 안정·성숙 단계라는 이유이며, 필요한 기능은 모두 들어있으므로 본선 선택은 유효하다.**
</details>

## 검증 표 (발췌)

`ARCH` = GitHub 아카이브(읽기 전용). 전체 표는 [조사 보고서](./docs/01-research-report.md) 참조.

| 저장소 | ★ | 라이선스 | ARCH | 최종 푸시 | 유형 |
|---|---:|---|:---:|---|---|
| [GPT-SoVITS](https://github.com/RVC-Boss/GPT-SoVITS) | 60,209 | MIT | | 2026-07-22 | TTS/클로닝 |
| [VibeVoice](https://github.com/microsoft/VibeVoice) | 51,246 | MIT | | 2026-07-24 | TTS (장문) |
| [OpenVoice](https://github.com/myshell-ai/OpenVoice) | 37,048 | MIT | | 2025-04-19 | 음색 변환 |
| [**RVC-WebUI**](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) | **36,802** | **MIT** | | 2026-07-23 | **VC** |
| [fish-speech](https://github.com/fishaudio/fish-speech) | 31,633 | **상업 금지** | | 2026-07-26 | TTS |
| [so-vits-svc](https://github.com/svc-develop-team/so-vits-svc) | 28,152 | AGPL-3.0 | **YES** | 2023-11-11 | SVC |
| [**Chatterbox**](https://github.com/resemble-ai/chatterbox) | **25,763** | **MIT** | | 2026-07-21 | **VC + TTS** |
| [CosyVoice](https://github.com/FunAudioLLM/CosyVoice) | 22,483 | Apache-2.0 | | 2026-05-25 | TTS |
| [IndexTTS2](https://github.com/index-tts/index-tts) | 22,256 | bilibili 독자 | | 2026-07-14 | TTS (감정 제어) |
| [**VCClient**](https://github.com/w-okada/voice-changer) | **20,694** | **MIT** | | 2026-03-21 | **실시간 VC** |
| [**Applio**](https://github.com/IAHispano/Applio) | **3,531** | **MIT** | | 2026-07-29 | **RVC 프론트엔드** |
| [seed-vc](https://github.com/Plachtaa/seed-vc) | 3,893 | GPL-3.0 | **YES** | 2025-04-20 | 무학습 VC |

## 시작하기

### 1. 후보 저장소 검증 재현

```bash
gh auth login
./scripts/audit_repos.sh      # 별 수 / 라이선스 / 아카이브 / 최종 푸시일 재조회
```

> [!IMPORTANT]
> SPDX 배지가 `NOASSERTION`이면 **반드시 LICENSE 원문을 읽어야 한다.** fish-speech가 그 예다.

### 2. 연구 대상 저장소 받기

```bash
./scripts/fetch_repos.sh      # external/ 로 shallow clone (~330MB, 코드만)
```

`external/`은 `.gitignore` 처리돼 있다.

### 3. 배치 변환 (GPU 머신)

```bash
APPLIO_DIR=/path/to/Applio \
  ./scripts/convert_batch.sh ./raw/male_takes ./out/kawaii kawaii_v1
```

검증된 파라미터가 기본값으로 들어있다 — `korean-hubert-base` 임베더, 목표 F0 255Hz 자동 피치, 포먼트 시프팅 활성. 상세는 [제작 파이프라인](./docs/02-production-pipeline.md).

## 파이프라인

```
남성 성우 녹음 (감정·타이밍 그대로)
        ↓
Chatterbox VC 로 캐릭터 음색 방향 즉시 검증          [학습 0분, MIT]
        ↓
확정된 방향으로 여성 화자 데이터셋 확보              [권리 명시 계약]
        ↓
Applio 로 RVC 모델 학습        48kHz / korean-hubert-base / RefineGAN
        ↓
Applio batch_infer
  --embedder_model korean-hubert-base      ← 한국어 음소
  --proposed_pitch True --threshold 255    ← 클립별 자동 피치
  --formant_shifting True                  ← 성별 인지 교정
        ↓
디에서 → 라우드니스 정규화 → 무음 트림
        ↓
언리얼 (Sound Concurrency · 더킹 · 바크 쿨다운)
```

## ⚠️ 음성 권리 고지

> [!CAUTION]
> **소프트웨어 라이선스와 음성 데이터 권리는 완전히 별개다.**
> Applio가 MIT라는 사실은 *도구*를 자유롭게 쓸 수 있다는 뜻이지, *어떤 목소리로 학습해도 된다*는 뜻이 아니다.

**하지 말 것**

- ❌ 인터넷에 배포되는 **"애니 캐릭터 / 성우 RVC 모델" 사용** — 배포자에게 재라이선스 권한이 없는 경우가 대부분이다
- ❌ 애니메이션·게임·유튜브에서 추출한 음성으로 학습
- ❌ 실존 성우·연예인 목소리 모방

**할 것** — 직접 섭외한 화자를 녹음하고 계약서에 **AI 학습 / 음성 변환 합성 / 상업적 배포 / 2차 활용 범위 / 철회권 처리**를 명시한다. 남성 성우에게도 본인 음성이 변환되어 사용됨을 고지하고 동의를 받는다.

전체 체크리스트: [**라이선스 체크리스트**](./docs/04-licensing.md)

## 이 조사의 한계

> [!WARNING]
> **실제 오디오 변환은 수행하지 않았다.** 조사 환경에 GPU가 없고(4코어 CPU), 변환할 남성 음성 원본이 아직 없다.
> 음질 관련 서술은 소스 코드·라이선스에서 확인한 사실과 아키텍처적 추론이며, **최종 음색 판단은
> [제작 파이프라인](./docs/02-production-pipeline.md)의 파일럿 A/B 프로토콜**(대표 20개 대사 × 5개 축)로
> RTX 4080 랩톱에서 직접 해야 한다.

## 참고 프로젝트

이 조사는 다음 프로젝트들의 소스와 라이선스를 판독해 작성했다.

- [IAHispano/Applio](https://github.com/IAHispano/Applio) — `core.py`, `rvc/infer/pipeline.py`, `TERMS_OF_USE.md`
- [RVC-Project/Retrieval-based-Voice-Conversion-WebUI](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) — RVC 본체
- [resemble-ai/chatterbox](https://github.com/resemble-ai/chatterbox) — `src/chatterbox/vc.py`, `mtl_tts.py`
- [w-okada/voice-changer](https://github.com/w-okada/voice-changer) — 실시간 VCClient
- [RVC-Boss/GPT-SoVITS](https://github.com/RVC-Boss/GPT-SoVITS) · [FunAudioLLM/CosyVoice](https://github.com/FunAudioLLM/CosyVoice) · [myshell-ai/OpenVoice](https://github.com/myshell-ai/OpenVoice) — TTS 대안
- [index-tts/index-tts](https://github.com/index-tts/index-tts) · [fishaudio/fish-speech](https://github.com/fishaudio/fish-speech) — 라이선스 판독 대상
- [Plachtaa/seed-vc](https://github.com/Plachtaa/seed-vc) — 아카이브, 참고용
- 기반 기술: [ContentVec](https://github.com/auspicious3000/contentvec) · [RMVPE](https://github.com/Dream-High/RMVPE) · [VITS](https://github.com/jaywalnut310/vits) · [HiFi-GAN](https://github.com/jik876/hifi-gan)

## 라이선스

이 저장소의 **문서와 스크립트**는 [MIT 라이선스](./LICENSE)를 따른다.
여기서 다루는 외부 도구들의 라이선스는 각기 다르며, 일부는 상업적 사용이 제한된다 — [라이선스 체크리스트](./docs/04-licensing.md)를 확인할 것.

# 조사 보고서 — 남성 → 미소녀 여고생 음성 변환 (한국어 · 상업 게임)

조사일: **2026-07-30**
검증 방법: GitHub REST API 직접 조회 (별 수 / SPDX 라이선스 / 아카이브 여부 / 최종 푸시일) + 상위 10개 저장소 shallow clone 후 **라이선스 원문과 추론 코드 직접 판독**.

---

## 1. 후보 전수 검증 표

별 수 기준 정렬. `ARCH` = GitHub 아카이브(읽기 전용) 상태.

| 저장소 | ★ | 라이선스 | ARCH | 최종 푸시 | 유형 |
|---|---:|---|---|---|---|
| RVC-Boss/GPT-SoVITS | 60,209 | MIT | | 2026-07-22 | TTS/클로닝 |
| microsoft/VibeVoice | 51,242 | MIT | | 2026-07-24 | TTS (장문) |
| coqui-ai/TTS | 45,838 | MPL-2.0 | | 2024-08-16 | TTS (유지보수 중단) |
| 2noise/ChatTTS | 39,698 | **AGPL-3.0** | | 2026-04-10 | TTS |
| myshell-ai/OpenVoice | 37,048 | MIT | | 2025-04-19 | 음색 변환 + TTS |
| **RVC-Project/RVC-WebUI** | **36,801** | **MIT** | | 2026-07-23 | **VC (오디오→오디오)** |
| fishaudio/fish-speech | 31,630 | **상업 금지** | | 2026-07-26 | TTS |
| svc-develop-team/so-vits-svc | 28,152 | **AGPL-3.0** | **예** | 2023-11-11 | SVC |
| **resemble-ai/chatterbox** | **25,763** | **MIT** | | 2026-07-21 | **VC + 다국어 TTS** |
| Anjok07/ultimatevocalremovergui | 25,580 | MIT | | 2025-03-13 | 전처리(분리) |
| FunAudioLLM/CosyVoice | 22,483 | Apache-2.0 | | 2026-05-25 | TTS |
| index-tts/index-tts (IndexTTS2) | 22,256 | **bilibili 독자** | | 2026-07-14 | TTS (감정/길이 제어) |
| **w-okada/voice-changer** | **20,694** | **MIT** | | 2026-03-21 | **실시간 VC 클라이언트** |
| SWivid/F5-TTS | 15,041 | MIT | | 2026-07-23 | TTS |
| neonbjb/tortoise-tts | 14,865 | Apache-2.0 | | 2024-11-19 | TTS (구세대) |
| k2-fsa/sherpa-onnx | 13,856 | Apache-2.0 | | 2026-07-29 | 온디바이스 추론 |
| rhasspy/piper | 11,267 | MIT | **예** | 2025-08-26 | 경량 TTS |
| SparkAudio/Spark-TTS | 11,003 | Apache-2.0 | | 2025-04-09 | TTS |
| open-mmlab/Amphion | 9,973 | MIT | | 2026-03-25 | 연구 툴킷 (VC 레시피 포함) |
| boson-ai/higgs-audio | 8,304 | Apache-2.0 | | 2026-06-05 | 오디오 LLM |
| Zyphra/Zonos | 7,233 | Apache-2.0 | | 2025-03-05 | TTS |
| bytedance/MegaTTS3 | 6,080 | Apache-2.0 | | 2026-06-15 | TTS |
| **Plachtaa/seed-vc** | **3,893** | **GPL-3.0** | **예** | **2025-04-20** | 무학습 VC |
| **IAHispano/Applio** | **3,531** | **MIT** | | **2026-07-29** | **RVC 프론트엔드** |
| yxlllc/DDSP-SVC | 2,636 | MIT | | 2026-07-29 | 경량 SVC |
| resemble-ai/resemble-enhance | 2,375 | MIT | | 2024-12-03 | 후처리(복원) |

---

## 2. ChatGPT 답변 교차검증

ChatGPT의 방향(RVC 축, Applio 프론트엔드)은 **맞다.** 그러나 사실관계 4건이 틀렸고, 상업 출시에 중요한 항목이 누락됐다.

### 2.1 ❌ "Seed-VC 실시간 기능은 seed-vc-realtime 포크에서 계속 수정되고 있다"

**사실이 아니다.** `Plachtaa/seed-vc`는 아카이브 상태이고 최종 푸시는 **2025-04-20**이다.
저자 Plachtaa의 저장소를 전수 조회한 결과 `VALL-E-X`(7.9k), `VITS-fast-fine-tuning`(5.0k), `FAcodec`, `ASTRAL-quantization` **전부 아카이브**됐다.
"활발히 유지되는 실시간 포크"는 검색 결과 존재하지 않는다 — 확인된 파생 저장소는 별 14개, 4개, 0개 수준의 개인 저장소뿐이다.

→ **Seed-VC를 신규 도입할 이유가 없다.** 게다가 GPL-3.0이라 배포 시 검토 부담까지 있다.

### 2.2 ⭐ 누락: Chatterbox가 Seed-VC 자리를 대체한다 (MIT)

`resemble-ai/chatterbox` (25,763★, 활성)에는 **TTS와 별개로 음성 변환 클래스가 실제로 존재**한다:

```python
# external/chatterbox/src/chatterbox/vc.py
class ChatterboxVC:
    def set_target_voice(self, wav_fpath): ...
    def generate(self, audio, target_voice_path=None): ...
```

- **코드와 가중치 모두 MIT** (HuggingFace `ResembleAI/chatterbox` 확인) → 상업 게임에 가장 안전한 라이선스
- 학습 불필요. 참조 여성 음성 하나로 즉시 변환 → Seed-VC의 "오늘 바로 시험" 역할을 그대로 수행
- 다국어 TTS는 **한국어 포함 23개 언어** 지원 (`"ko": "Korean"` 확인)

**단, 소스를 읽고 확인한 3가지 제약:**
1. **모든 출력에 Perth 신경 워터마크가 삽입된다** (`self.watermarker.apply_watermark(...)`). MP3 압축·편집에도 살아남는다고 명시돼 있다. MIT라 제거는 법적으로 가능하지만, 삽입 사실 자체는 알고 있어야 한다.
2. 참조 음성은 **앞부분 10초만** 사용된다 (`DEC_COND_LEN = 10 * S3GEN_SR`).
3. **아키텍처상 RVC보다 연기 보존력이 낮다.** 소스를 S3 *의미 토큰*으로 변환한 뒤 재합성하므로 F0 곡선을 직접 운반하지 않는다. RVC는 F0를 명시적으로 추출·시프트해 넘긴다. → **최종 더빙 축은 여전히 RVC다.**

### 2.3 ⭐ 누락: Applio를 골라야 하는 진짜 이유는 GUI가 아니다

ChatGPT는 Applio를 "RVC를 쓰기 쉽게 만든 GUI"로 소개했다. 편의성은 부차적이고, 실제로는 **바닐라 RVC에 없는 기능 3개**가 이 프로젝트의 핵심 문제를 정확히 해결한다. (`external/Applio/core.py` 직접 확인)

**(1) `korean-hubert-base` 콘텐츠 임베더** — 한국어 게임에 결정적
```
--embedder_model {contentvec, spin, spin-v2, chinese-hubert-base,
                  japanese-hubert-base, korean-hubert-base, custom}
```
바닐라 RVC는 `contentvec`(영어 중심) 뿐이다. 한국어 전용 HuBERT를 쓰면 한국어 음소·받침·경음 보존이 개선된다. **기본값이 `contentvec`이므로 반드시 명시적으로 바꿔야 한다.**

**(2) 포먼트 시프팅** — "여성 음색인데 남자 같다" 문제의 실제 해법
```
--formant_shifting  --formant_qfrency  --formant_timbre
```
ChatGPT는 이 문제를 "단점"으로만 적고 대책을 주지 않았다. 성별 인지의 상당 부분은 F0가 아니라 **성도 길이 = 포먼트 위치**에서 온다. 피치만 올리면 "빠르게 감은 남성 목소리"가 된다. Applio는 이 축을 직접 만질 수 있다.

**(3) 클립별 자동 피치 계산** — 아래 2.4에서 상술

### 2.4 ⚠️ "음높이를 +8~+12 반음으로 시험한다" — 배치 작업에서 위험한 조언

수백 개 대사를 고정 오프셋으로 처리하면 안 된다. 성우의 중심 피치는 **테이크마다 달라진다** (외침 vs 속삭임에서 한 옥타브 차이가 난다). 고정 +12는 외침 대사에서 과보정돼 삑사리가 난다.

Applio는 클립별로 필요한 시프트를 직접 계산한다. `external/Applio/rvc/infer/pipeline.py`:

```python
limit = 12
median_f0 = float(np.median(...))
up_key = max(-limit, min(limit,
    int(np.round(12 * np.log2(proposed_pitch_threshold / median_f0)))))
print("calculated pitch offset:", up_key)
f0 *= pow(2, (pitch + up_key) / 12)
```

즉 `--proposed_pitch True --proposed_pitch_threshold 255` 로 두면 파일별 중위 F0를 측정해 목표 255Hz에 맞는 반음 수를 ±12 범위에서 자동 산출한다. 코드 주석에 기준값이 명시돼 있다: `155.0 for male, 255.0 for female`.

**여기서 실수하기 쉬운 지점 2개 (소스 확인):**
- 마지막 줄이 `pitch + up_key`다. 자동 피치를 쓰면서 `--pitch 12`를 같이 주면 **한 옥타브 이중 시프트**가 된다. 자동을 쓸 땐 `--pitch 0`으로 두고 미세 조정만 ±1~2로 준다.
- `--proposed_pitch_threshold` **기본값이 155.0(남성)** 이다. 그대로 두면 남성→남성 보정이라 목적에 맞지 않는다. 반드시 255를 명시할 것.
- `--proposed_pitch`는 `type=bool`로 선언돼 있어(다른 플래그들은 `strtobool` 사용) **`--proposed_pitch False`를 넘기면 `bool("False") == True`가 되어 켜진다.** 끄려면 인자를 아예 넘기지 말아야 한다.

### 2.5 ❌ 누락된 라이선스 함정: fish-speech는 상업적 사용 금지

"2026 최고의 오픈소스 더빙 모델" 류 블로그는 지금도 `fish-speech`를 최상위로 추천한다. 그런데 실제 라이선스 원문(**2026-03-07 개정**)은 다음과 같다:

> **FISH AUDIO RESEARCH LICENSE AGREEMENT**
> "This Agreement is intended to allow research and non-commercial uses of the Materials free of charge. **Any Commercial use of the Materials requires a separate license from Fish Audio.**"
> "Commercial Purpose" ... includes "(i) creating, modifying, or distributing Your product or service ... (iii) any use in connection with a product or service for which You charge a fee or generate revenue, **whether directly or indirectly**"

**유료 게임은 물론이고 광고·인앱결제 등 간접 수익까지 포함된다. 별도 계약 없이는 쓸 수 없다.** GitHub 배지에는 `NOASSERTION`으로만 표시되므로 배지만 보고 판단하면 사고가 난다.

### 2.6 그 외 정정

| ChatGPT 서술 | 검증 결과 |
|---|---|
| Applio를 1순위로 제시 | 방향은 타당. 단 별 수는 3,531로 RVC 본체(36,801)의 1/10 — "RVC 생태계의 프론트엔드"로 이해할 것 |
| so-vits-svc 미언급 | **아카이브(2023-11-11) + AGPL-3.0.** 전염성 라이선스라 게임에 부적합. 언급 안 한 게 맞다 |
| OpenVoice V2 "한국어 지원, MIT, 상업적 사용 가능" | **사실 확인.** 단 최종 푸시 2025-04-19로 정체 상태. GPT-SoVITS가 대체 |
| GPT-SoVITS 미언급 | **이 분야 최대 저장소(60,209★, MIT, 한국어 지원, 활성).** 큰 누락 |
| w-okada 라이선스 미언급 | LICENSE 원문 **MIT** 확인 (배지는 부속 NOTICE 때문에 NOASSERTION) |

---

## 3. 왜 RVC가 축인가 (아키텍처 근거)

| 계열 | 입력 | 성우 테이크 보존 | 이 프로젝트 적합성 |
|---|---|---|---|
| **RVC (Applio)** | 오디오 | **높음** — F0 곡선을 명시적으로 추출·시프트해 전달 | ✅ **본선** |
| Chatterbox VC | 오디오 | 중간 — 의미 토큰 경유로 미세 억양 일부 손실 | ⚠️ 프로토타입용 |
| TTS 계열 (GPT-SoVITS, IndexTTS2, CosyVoice) | **텍스트** | **없음** — 대사를 새로 생성 | 대안 경로 |

핵심은 이것이다. **연기·호흡·타이밍을 살리려면 오디오→오디오여야 한다.** 남성 성우를 섭외해 감정 연기를 받는 이유 자체가 그 테이크를 쓰기 위한 것이므로, 텍스트에서 다시 만드는 TTS는 목적과 상충한다. 탑다운 슈터의 짧은 전투 대사("뒤에!", "재장전!", "맞았어!")는 타이밍이 곧 게임 피드백이라 특히 그렇다.

**단, ChatGPT가 옳게 지적한 한계를 반복해 강조한다:** 음성 변환은 *음색*을 바꾸지만 *연기*를 바꾸지 않는다. 남성적 억양으로 읽으면 결과는 "여성 음색을 가진 남성 연기"가 된다. → [03-voice-direction.md](03-voice-direction.md)

## 4. 만약 TTS 경로를 병행한다면

전투 중 무한 생성되는 시스템 보이스나 대사량이 폭증할 때의 대안. 라이선스 안전 순서:

1. **GPT-SoVITS** (60.2k★, **MIT**, 한국어) — 라이선스가 가장 깨끗하고 활성도 최고. 1순위 대안.
2. **CosyVoice2** (22.5k★, **Apache-2.0**, 한국어 명시) — 스트리밍 저지연.
3. **Chatterbox 다국어 TTS** (25.8k★, **MIT**, 한국어) — VC와 스택 공유 가능.
4. **IndexTTS2** (22.3k★, **bilibili 독자 라이선스**) — 더빙에 유용한 *길이 제어 + 감정 분리*를 제공. 라이선스 원문 확인 결과 **MAU 1억 / 연매출 10억 위안 미만이면 무상 상업 사용 가능**하나, OSI 오픈소스가 아니고 파생물 고지 의무·타 AI 모델 학습 금지 조항이 있다. 인디 규모라면 사용 가능하지만 조항 준수 필요.
5. ~~fish-speech~~ — **상업 금지.** 제외.
6. ~~ChatTTS~~ — AGPL-3.0. 제외 권장.

## 5. 최종 권고

```
남성 성우 녹음 (감정·타이밍 그대로)
        ↓
Chatterbox VC 로 캐릭터 음색 방향 즉시 검증 (학습 0분, MIT)
        ↓
확정된 방향으로 여성 화자 데이터셋 확보 (권리 명시 계약)
        ↓
Applio 로 RVC 모델 학습
        ↓
Applio batch_infer
  --embedder_model korean-hubert-base      ← 한국어 음소
  --proposed_pitch True --threshold 255    ← 클립별 자동 피치
  --formant_shifting True                  ← 성별 인지 교정
        ↓
후처리 → 라우드니스 정규화 → 언리얼
```

실시간 모니터링이 필요하면 녹음 부스에 **w-okada VCClient**(MIT)를 걸어 성우가 변환 결과를 들으며 연기를 조정하게 한다. 단 최종 납품물은 오프라인 배치 변환본을 쓴다(실시간은 버퍼·드롭 영향).

상세 파라미터와 파일럿 검증 절차: [02-production-pipeline.md](02-production-pipeline.md)

---

## 출처

- GitHub REST API (`repos/{owner}/{repo}`) — 별 수·SPDX·아카이브·푸시일, 2026-07-30 조회
- 클론 후 직접 판독: `Applio/core.py`, `Applio/rvc/infer/pipeline.py`, `chatterbox/src/chatterbox/vc.py`, `index-tts/LICENSE`, `voice-changer/LICENSE`, `fish-speech/LICENSE`, `CosyVoice/README.md`, `OpenVoice/docs/USAGE.md`, `GPT-SoVITS/README.md`
- [ResembleAI/chatterbox (HuggingFace)](https://huggingface.co/ResembleAI/chatterbox) — 가중치 MIT, Perth 워터마크 명시
- [w-okada/voice-changer](https://github.com/w-okada/voice-changer) · [RVC 튜토리얼](https://github.com/w-okada/voice-changer/blob/master/tutorials/tutorial_rvc_en_latest.md)
- [Retrieval-based Voice Conversion (Wikipedia)](https://en.wikipedia.org/wiki/Retrieval-based_Voice_Conversion)
- [The Best Open Source AI Models for Dubbing in 2026 (SiliconFlow)](https://www.siliconflow.com/articles/en/best-open-source-AI-models-for-dubbing) — fish-speech를 추천하나 **라이선스 검증 결과 상업 사용 불가**
- [Best Open Source AI Voice Cloning Tools in 2026 (Resemble AI)](https://www.resemble.ai/resources/best-open-source-ai-voice-cloning-tools)

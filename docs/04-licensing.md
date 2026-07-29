# 라이선스 · 권리 체크리스트 (상업 출시)

> 법률 자문이 아니다. 출시 전 변호사 검토를 전제로 한 실무 체크리스트다.
> 라이선스 정보는 2026-07-30 기준으로 각 저장소의 LICENSE 원문을 직접 판독한 결과다.

## 핵심 원칙

**소프트웨어 라이선스와 음성 데이터 권리는 완전히 별개다.**
Applio가 MIT라는 사실은 *도구*를 자유롭게 쓸 수 있다는 뜻이지, *어떤 목소리로 학습해도 된다*는 뜻이 아니다. 실제 리스크는 대부분 후자에서 발생한다.

## 1. 소프트웨어 라이선스

| 도구 | 라이선스 | 상업 게임 | 비고 |
|---|---|---|---|
| **IAHispano/Applio** | MIT | ✅ | 코드 및 저장소 기본 가중치 |
| **RVC-Project/RVC-WebUI** | MIT | ✅ | |
| **resemble-ai/chatterbox** | MIT | ✅ | **가중치도 MIT.** 출력에 Perth 워터마크 삽입 |
| **w-okada/voice-changer** | MIT | ✅ | LICENSE 원문 MIT (배지는 부속 NOTICE 때문에 NOASSERTION) |
| **RVC-Boss/GPT-SoVITS** | MIT | ✅ | |
| **FunAudioLLM/CosyVoice** | Apache-2.0 | ✅ | |
| **myshell-ai/OpenVoice** | MIT | ✅ | 최종 푸시 2025-04, 정체 상태 |
| index-tts (IndexTTS2) | **bilibili 독자** | ⚠️ 조건부 | 아래 3절 |
| **fishaudio/fish-speech** | **Research License** | ❌ **금지** | 아래 2절 |
| 2noise/ChatTTS | AGPL-3.0 | ❌ 권장 안 함 | 전염성 |
| svc-develop-team/so-vits-svc | AGPL-3.0 + 아카이브 | ❌ | |
| Plachtaa/seed-vc | GPL-3.0 + 아카이브 | ⚠️ | 신규 도입 이유 없음 |

### GPL / AGPL 관련 정리

**변환된 WAV 파일을 게임에 넣는 것**과 **프로그램 자체를 게임 빌드에 포함·배포하는 것**은 다른 문제다.
- 오프라인으로 도구를 돌려 나온 오디오 산출물만 게임에 넣는다 → 일반적으로 도구의 copyleft가 게임 코드에 전파되지 않는다.
- 도구를 언리얼 빌드에 링크해 **런타임 변환**을 넣는다 → GPL/AGPL은 소스 공개 의무를 유발할 수 있다. **이 경로는 MIT/Apache 도구만 쓴다.**

이 프로젝트는 오프라인 배치 변환이므로 실무상 안전하지만, **어차피 MIT 도구(Applio/Chatterbox)로 전부 해결되므로 GPL 계열을 쓸 이유가 없다.**

## 2. ⚠️ fish-speech — 상업적 사용 금지

여러 "2026 최고의 오픈소스 더빙 모델" 블로그가 지금도 최상위로 추천하지만, LICENSE 원문(**2026-03-07 개정**)은 다음과 같다.

> **FISH AUDIO RESEARCH LICENSE AGREEMENT**
> "This Agreement is intended to allow research and non-commercial uses of the Materials free of charge. **Any Commercial use of the Materials requires a separate license from Fish Audio.**"
>
> "Commercial Purpose" means ... "(i) creating, modifying, or distributing Your product or service ... (iii) any use in connection with a product or service for which You charge a fee or generate revenue, **whether directly or indirectly**"

- 유료 게임뿐 아니라 **광고·인앱결제 등 간접 수익도 포함**된다.
- GitHub 배지에는 `NOASSERTION`으로만 뜬다. **배지를 신뢰하지 말고 LICENSE 원문을 읽어야 한다.**
- 사용하려면 Fish Audio와 별도 서면 계약이 필요하다.

## 3. ⚠️ IndexTTS2 — 조건부 허용 (OSI 오픈소스 아님)

`index-tts/index-tts`는 **bilibili Model Use License Agreement**를 따른다. 원문 확인 결과:

- **§2.2** — MAU 1억 초과 또는 전년도 연매출 10억 위안 초과 시 별도 라이선스 필요. **인디 규모는 무상 상업 사용 가능.**
- **§2.x(c)** — 이 모델(및 파생물)을 제외한 **다른 AI 모델 개선에 사용 금지.** → 출력을 다른 모델 학습에 쓰면 위반.
- **§4.1(a)** — 파생물 배포 시 "원저작권자가 보증하지 않는다"는 고지문 게재 의무.
- **§4.3** — 제3자 클레임 시 사용자가 전적으로 책임지고 bilibili를 면책.

더빙에 유용한 *길이 제어 + 감정 분리* 기능이 있어 매력적이지만, MIT인 GPT-SoVITS로 대체 가능하다면 그쪽이 관리 부담이 적다.

## 4. 🔴 최대 리스크 — 음성 데이터 권리

**여기가 실제로 게임을 위험하게 만드는 부분이다.**

### 절대 하지 말 것

- ❌ 인터넷에 배포되는 **"애니 캐릭터 / 성우 RVC 모델"을 그대로 사용** — 원 성우의 권리 침해 소지. 게임 출시용으로 쓸 수 없다.
- ❌ 애니메이션·게임·유튜브에서 추출한 음성으로 학습
- ❌ 실존 성우·연예인 목소리 모방
- ❌ "무료 배포 모델이니 괜찮다"는 판단 — **배포자에게 재라이선스 권한이 없는 경우가 대부분이다.**

### 해야 할 것

**직접 섭외한 여성 화자**를 녹음하고, 계약서에 다음을 명시한다.

- [ ] **AI 음성 모델 학습** 목적 이용 허락
- [ ] **음성 변환(voice conversion) 합성물** 생성 및 이용 허락
- [ ] **상업적 배포** 범위 — 게임 본편 / 트레일러 / 광고 / 굿즈 / 스핀오프
- [ ] **플랫폼·지역·기간** 범위 (전세계·영구 여부)
- [ ] **캐릭터 목소리로서의 2차 활용** 범위 (DLC, 후속작, 콜라보)
- [ ] **학습된 모델 가중치의 소유·보관 주체**
- [ ] 화자 **크레딧 표기** 방식
- [ ] 화자 **철회권** 유무 및 철회 시 처리 (출시된 게임에서 회수 불가능하므로 사전 합의 필수)
- [ ] 남성 성우에게도 **본인 음성이 변환되어 사용됨**을 고지하고 동의 취득

### 한국 법 관련 (변호사 확인 필요)

- **부정경쟁방지법** — 타인의 성명·초상·음성 등 인적 표지를 무단으로 상업적 이용하는 행위를 부정경쟁행위로 규율하는 조항이 있다. 실존 인물 음성 모방은 이 조항의 사정권에 들어갈 수 있다.
- **개인정보보호법** — 음성은 개인 식별 가능 정보로 취급될 수 있다. 학습 데이터 수집·보관에 동의 절차와 보관 정책이 필요하다.
- **저작권법** — 음원 자체의 저작인접권(실연자의 권리)이 별도로 존재한다.
- **플랫폼 정책** — Steam 등은 AI 생성 콘텐츠 사용 시 **사전 신고 의무**를 두고 있다. 출시 심사 단계에서 막히지 않도록 사용 도구·학습 데이터 권리 근거를 문서로 정리해 둘 것.

## 5. Chatterbox 워터마크

`ChatterboxVC.generate()`는 모든 출력에 Perth 신경 워터마크를 삽입한다.

```python
watermarked_wav = self.watermarker.apply_watermark(wav, sample_rate=self.sr)
```

- MP3 압축·편집·일반적 가공에도 살아남는다고 명시돼 있다.
- 사람 귀에는 들리지 않으므로 게임 오디오 품질에는 영향이 없다.
- MIT 라이선스이므로 제거는 법적으로 가능하나, Resemble AI의 책임 있는 AI 정책이다. **삽입 사실을 알고 결정할 문제다.**
- Chatterbox는 프로토타입 단계에서만 쓰고 최종 납품물은 Applio/RVC에서 나오므로, 실무상 쟁점이 되지 않는다.

## 6. 출시 전 최종 확인

- [ ] 사용한 모든 도구의 라이선스 원문 확인 (배지 아님)
- [ ] MIT/Apache 도구만 사용했는지 확인
- [ ] 학습 데이터 전량의 권리 문서 확보
- [ ] 화자 계약서에 AI 학습·변환·상업 배포 명시 확인
- [ ] 남성 성우 동의서 확보
- [ ] 인터넷 배포 모델 미사용 확인
- [ ] 플랫폼 AI 콘텐츠 신고 요건 충족
- [ ] 크레딧에 사용 OSS 및 라이선스 고지
- [ ] 변호사 최종 검토

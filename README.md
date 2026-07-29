# KawaiiVoice

탑다운 슈터 서브컬쳐 게임(Unreal Engine)의 한국어 더빙 파이프라인 연구.
**30세 남성 성우의 연기를 미소녀 여고생 음색으로 변환**하는 것이 목표.

> 이 저장소는 코드가 아니라 **검증된 기술 선택 근거**를 담는다.
> 모든 별 수 / 라이선스 / 아카이브 여부는 GitHub API로 직접 조회했고,
> 라이선스 조항과 파라미터는 실제 클론한 소스에서 읽어 확인했다. (조사 기준일 2026-07-30)

## 결론 요약

| 용도 | 선택 | 라이선스 | 근거 |
|---|---|---|---|
| **게임 최종 더빙 (본선)** | **Applio** (RVC 프론트엔드) | MIT | `korean-hubert-base` 임베더 + 포먼트 시프팅 + 클립별 자동 피치 |
| **오늘 바로 무학습 테스트** | **Chatterbox `ChatterboxVC`** | MIT (코드·가중치) | 학습 없이 참조음성만으로 변환, 상업적 사용 안전 |
| **녹음 중 실시간 모니터링** | **w-okada VCClient** | MIT | 성우가 결과를 들으며 연기 조정 |
| **대사 재합성이 허용될 때** | **GPT-SoVITS** | MIT | 60k★, 한국어 지원, 현재 이 분야 최대 활성 저장소 |

**핵심 판단: 연기·호흡·타이밍을 보존해야 하므로 축은 RVC(오디오→오디오)다. TTS 계열은 대사를 다시 만드는 것이라 성우의 테이크가 사라진다.**

## 문서

| 문서 | 내용 |
|---|---|
| [01-research-report.md](docs/01-research-report.md) | **메인 보고서** — 후보 20종 검증 비교, ChatGPT 답변 교차검증 |
| [02-production-pipeline.md](docs/02-production-pipeline.md) | 실제 제작 파이프라인과 검증된 파라미터 |
| [03-voice-direction.md](docs/03-voice-direction.md) | 남성 성우 연기 디렉션, 타겟 여성 음성 데이터셋 구축 |
| [04-licensing.md](docs/04-licensing.md) | 상업 출시 라이선스·권리 체크리스트 |
| [05-unreal-integration.md](docs/05-unreal-integration.md) | 언리얼 엔진 통합, 탑다운 슈터 특성 반영 |

## 스크립트

```bash
scripts/audit_repos.sh      # 후보 저장소 별 수/라이선스/아카이브 여부 재검증
scripts/fetch_repos.sh      # 연구 대상 저장소 shallow clone (external/, git 제외)
scripts/convert_batch.sh    # Applio 배치 변환 (한국어 임베더 + 자동 피치)
```

## 이 환경에 대한 참고

조사는 GPU가 없는 Linux 박스에서 수행했다. **실제 추론·학습은 사용자의 RTX 4080 랩톱에서 실행해야 한다.**
변환할 남성 음성 원본이 아직 없으므로 **실제 오디오 변환은 수행하지 않았다.** 보고서의 음질 관련 서술은
소스 코드·논문·라이선스에서 확인한 사실과 아키텍처적 추론이며, 최종 음색 판단은
[02-production-pipeline.md](docs/02-production-pipeline.md)의 파일럿 A/B 테스트로 직접 해야 한다.

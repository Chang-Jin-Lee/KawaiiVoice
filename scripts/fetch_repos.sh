#!/usr/bin/env bash
# 연구 대상 저장소를 external/ 로 shallow clone.
# external/ 은 .gitignore 처리돼 있으므로 이 저장소에는 커밋되지 않는다.
#
# 사용법: ./scripts/fetch_repos.sh
#
# 가중치는 포함되지 않는다(코드만). 총 ~330MB.
# 실제 추론/학습은 GPU 머신(RTX 4080 랩톱)에서 각 저장소의 설치 절차를 따를 것.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/external"
mkdir -p "$DEST"

REPOS=(
  IAHispano/Applio                                    # 본선: RVC 프론트엔드 (MIT)
  RVC-Project/Retrieval-based-Voice-Conversion-WebUI   # RVC 본체 (MIT)
  resemble-ai/chatterbox                              # 무학습 VC + 한국어 TTS (MIT)
  w-okada/voice-changer                               # 실시간 모니터링 (MIT)
  RVC-Boss/GPT-SoVITS                                 # TTS 대안 1순위 (MIT)
  FunAudioLLM/CosyVoice                               # TTS 대안 (Apache-2.0)
  myshell-ai/OpenVoice                                # 음색 변환 (MIT, 정체)
  index-tts/index-tts                                 # 감정/길이 제어 (bilibili 독자 라이선스)
  yxlllc/DDSP-SVC                                     # 경량 SVC (MIT)
  Plachtaa/seed-vc                                    # 참고용 (GPL-3.0, 아카이브됨)
)

for r in "${REPOS[@]}"; do
  name="$(basename "$r")"
  if [ -d "$DEST/$name" ]; then
    echo "skip   $name (이미 존재)"
    continue
  fi
  echo "clone  $name"
  git clone --depth 1 --quiet "https://github.com/$r.git" "$DEST/$name" \
    || echo "FAILED $name"
done

echo
du -sh "$DEST"/*/ 2>/dev/null | sort -h
echo
echo "라이선스 원문 확인:"
for f in "$DEST"/*/LICENSE; do
  [ -f "$f" ] && printf '  %-24s %s\n' "$(basename "$(dirname "$f")")" "$(head -1 "$f")"
done

#!/usr/bin/env bash
# 후보 저장소의 별 수 / 라이선스 / 아카이브 여부 / 최종 푸시일을 GitHub API로 재검증.
# docs/01-research-report.md 의 비교표를 생성한 스크립트.
#
# 사용법: gh auth login 후  ./scripts/audit_repos.sh
#
# 주의: SPDX 배지가 NOASSERTION 이면 반드시 LICENSE 원문을 직접 읽어야 한다.
#       fish-speech 는 배지상 NOASSERTION 이지만 실제로는 상업적 사용 금지다.

set -uo pipefail

command -v gh >/dev/null || { echo "gh CLI 필요"; exit 1; }

REPOS=(
  # --- 음성 변환 (오디오 → 오디오): 이 프로젝트의 본선 ---
  RVC-Project/Retrieval-based-Voice-Conversion-WebUI
  IAHispano/Applio
  resemble-ai/chatterbox
  w-okada/voice-changer
  Plachtaa/seed-vc
  svc-develop-team/so-vits-svc
  yxlllc/DDSP-SVC
  open-mmlab/Amphion
  OlaWod/FreeVC
  bshall/knn-vc
  # --- TTS / 음성 클로닝 (대안 경로) ---
  RVC-Boss/GPT-SoVITS
  microsoft/VibeVoice
  coqui-ai/TTS
  2noise/ChatTTS
  myshell-ai/OpenVoice
  myshell-ai/MeloTTS
  fishaudio/fish-speech
  FunAudioLLM/CosyVoice
  index-tts/index-tts
  SWivid/F5-TTS
  SparkAudio/Spark-TTS
  boson-ai/higgs-audio
  Zyphra/Zonos
  bytedance/MegaTTS3
  neonbjb/tortoise-tts
  # --- 전처리 / 후처리 / 런타임 ---
  Anjok07/ultimatevocalremovergui
  resemble-ai/resemble-enhance
  Rikorose/DeepFilterNet
  k2-fsa/sherpa-onnx
  rhasspy/piper
)

printf '%-58s %8s  %-14s %-5s %-11s %s\n' REPO STARS LICENSE ARCH PUSHED LANG
printf '%.0s-' {1..112}; echo

for r in "${REPOS[@]}"; do
  out=$(gh api "repos/$r" \
    --jq '[(.stargazers_count|tostring),(.license.spdx_id // "NONE"),(if .archived then "YES" else "-" end),.pushed_at[0:10],(.language // "-")] | @tsv' 2>/dev/null)
  if [ -z "$out" ]; then
    printf '%-58s %8s\n' "$r" "N/A"
  else
    IFS=$'\t' read -r stars lic arch pushed lang <<<"$out"
    printf '%-58s %8s  %-14s %-5s %-11s %s\n' "$r" "$stars" "$lic" "$arch" "$pushed" "$lang"
  fi
done

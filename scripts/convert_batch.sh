#!/usr/bin/env bash
# Applio 배치 변환 래퍼 — 남성 녹음 폴더 → 미소녀 여고생 음색
#
# GPU 머신(RTX 4080 랩톱)의 Applio 설치 디렉터리에서 실행할 것.
#   APPLIO_DIR=/path/to/Applio ./convert_batch.sh <input_dir> <output_dir> <model_name>
#
# 파라미터 근거는 docs/02-production-pipeline.md 참조.
# 모든 값은 Applio core.py / rvc/infer/pipeline.py 원문에서 확인했다.

set -euo pipefail

IN="${1:?사용법: convert_batch.sh <input_dir> <output_dir> <model_name>}"
OUT="${2:?출력 디렉터리 필요}"
MODEL="${3:?모델명 필요 (logs/<model_name>/ 아래를 찾는다)}"

APPLIO_DIR="${APPLIO_DIR:-.}"
cd "$APPLIO_DIR"

PTH="./logs/${MODEL}/${MODEL}.pth"
IDX="$(ls ./logs/${MODEL}/added_*.index 2>/dev/null | head -1 || true)"

[ -f "$PTH" ] || { echo "모델 없음: $PTH"; exit 1; }
[ -n "$IDX" ] || { echo "인덱스 없음: ./logs/${MODEL}/added_*.index — core.py index 먼저 실행"; exit 1; }

mkdir -p "$OUT"

# ─── 튜닝 가능 ───────────────────────────────────────────────────────────
TARGET_HZ="${TARGET_HZ:-255}"      # 여성 목표 F0. pipeline.py 주석: 155=남성, 255=여성
PITCH_TRIM="${PITCH_TRIM:-0}"      # 자동 피치에 '합산'되는 미세 조정. 보통 0, 필요시 ±1~2
INDEX_RATE="${INDEX_RATE:-0.5}"    # 타겟 음색 강도. 높으면 아티팩트↑ (기본 0.3)
PROTECT="${PROTECT:-0.33}"         # 자음·호흡 보호. 0.5가 최대
F0_METHOD="${F0_METHOD:-rmvpe}"    # 외침에서 불안정하면 hybrid[rmvpe+fcpe]
EMBEDDER="${EMBEDDER:-korean-hubert-base}"   # ★ 한국어 음소 보존. 학습 때와 반드시 일치
FORMANT="${FORMANT:-True}"         # ★ 성도 길이 보정 — "여성 음색인데 남자 같다"의 해법
FORMANT_Q="${FORMANT_Q:-1.0}"
FORMANT_T="${FORMANT_T:-1.0}"
# ────────────────────────────────────────────────────────────────────────

echo "입력      : $IN"
echo "출력      : $OUT"
echo "모델      : $PTH"
echo "임베더    : $EMBEDDER"
echo "목표 F0   : ${TARGET_HZ}Hz (클립별 자동 산출, ±12 반음 클램프)"
echo "피치 보정 : ${PITCH_TRIM} (자동값에 합산)"
echo

# 주의: --proposed_pitch 는 type=bool 로 선언돼 있어 'False' 를 넘겨도 True 가 된다.
#       끄고 싶으면 아래 두 줄을 지울 것 (값을 False 로 바꾸는 것으로는 안 꺼진다).
python core.py batch_infer \
  --input_folder  "$IN" \
  --output_folder "$OUT" \
  --pth_path      "$PTH" \
  --index_path    "$IDX" \
  --embedder_model "$EMBEDDER" \
  --f0_method      "$F0_METHOD" \
  --proposed_pitch True \
  --proposed_pitch_threshold "$TARGET_HZ" \
  --pitch          "$PITCH_TRIM" \
  --index_rate     "$INDEX_RATE" \
  --protect        "$PROTECT" \
  --volume_envelope 1 \
  --formant_shifting "$FORMANT" \
  --formant_qfrency  "$FORMANT_Q" \
  --formant_timbre   "$FORMANT_T" \
  --export_format WAV

echo
echo "완료. 다음 단계 — 디에서 → 라우드니스 정규화 → 무음 트림:"
echo '  for f in '"$OUT"'/*.wav; do'
echo '    ffmpeg -i "$f" -af loudnorm=I=-18:TP=-1.5:LRA=7 -ar 48000 -c:a pcm_s24le "${f%.wav}_norm.wav"'
echo '  done'

# 공식 이미지 버전 핀 (= v0.16.0 "The Surface Release"). latest 금지 — 업그레이드는 의도적으로 (guide §12)
FROM nousresearch/hermes-agent:v2026.6.5

# 워커들이 반복 사용하는 도구만 이미지에 굽는다 (ripgrep·node·npm은 베이스에 내장).
# 실험은 docker exec로 설치 → 정착한 도구만 여기로 승격 (exec 설치분은 컨테이너 재생성 시 증발)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# coder의 실행 엔진: 컨테이너 전용 Claude Code (호스트 설치본과 무관, 버전 독립)
RUN npm install -g @anthropic-ai/claude-code@2.1.175

# docker exec 직접 호출에서도 hermes/claude가 PATH에 잡히게 (entrypoint 래퍼는 venv를 직접 activate)
ENV PATH="/opt/hermes/.venv/bin:${PATH}"

# ❌ 금지: COPY .env / ENV API_KEY=...  — 이미지 레이어에 영구히 박힘

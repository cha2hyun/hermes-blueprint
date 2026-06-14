#!/usr/bin/env bash
# Hermes blueprint installer — 클론 후 1회 실행.
# 루트 .env의 공통 키(ANTHROPIC_API_KEY)를 각 프로파일 .env로 전파하고
# 런타임 디렉터리를 생성한다. 시크릿 값은 화면에 출력하지 않는다.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "── Hermes blueprint installer ──"

# 1) 런타임 디렉터리 (git에서 제외되는 것들 — 클론본엔 없으므로 생성)
mkdir -p .hermes && chmod 700 .hermes
mkdir -p workspace/dev/{specs,design,qa-reports,worktrees} \
         workspace/invest/{data,reports} workspace/ops \
         repos/dev repos/invest
echo "✅ 디렉터리 구조 준비"

# 2) 루트 .env 확인 (공통 키 출처)
if [ ! -f .env ]; then
  cp .env.example .env
  echo "❌ 루트 .env가 없어 .env.example을 복사했습니다."
  echo "   .env에 ANTHROPIC_API_KEY를 입력한 뒤 다시 실행하세요."
  exit 1
fi
ANTHROPIC_API_KEY="$(grep -E '^ANTHROPIC_API_KEY=' .env | head -1 | cut -d= -f2-)"
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "❌ .env의 ANTHROPIC_API_KEY가 비어 있습니다. 입력 후 다시 실행하세요."
  exit 1
fi
echo "✅ 루트 .env에서 공통 키 확인"

# 3) 각 프로파일 .env 생성 (.env.template 기반, 공통 키 주입, 멱등)
for tmpl in .hermes/profiles/*/.env.template; do
  [ -e "$tmpl" ] || { echo "⚠️ .env.template 없음 — 프로파일을 먼저 생성하세요(가이드 §4)"; break; }
  pdir="$(dirname "$tmpl")"; name="$(basename "$pdir")"; env="$pdir/.env"
  if [ -f "$env" ]; then
    echo "ℹ️ ${name}/.env 이미 존재 — 건너뜀"
    continue
  fi
  cp "$tmpl" "$env"
  sed -i.bak "s|^ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}|" "$env" && rm -f "$env.bak"
  chmod 600 "$env"
  echo "✅ ${name}/.env 생성 (공통 키 주입, 권한 600)"
done

# 4) 오케스트레이터 추가 입력 안내 (Discord 셋업 후 — 봇 토큰/채널ID/사용자ID)
cat <<'GUIDE'

── 다음 단계 (오케스트레이터만 추가 입력) ──
Discord 봇 3개 + 채널 셋업 후, 아래 .env에 봇 토큰·채널ID·본인 사용자ID 입력:
  .hermes/profiles/dev-orchestrator/.env     DISCORD_BOT_TOKEN, DISCORD_DEV_CHANNEL, DISCORD_ALLOWED_USERS
  .hermes/profiles/invest-orchestrator/.env  DISCORD_BOT_TOKEN, DISCORD_INVEST_CHANNEL, DISCORD_ALLOWED_USERS
  .hermes/profiles/ops-orchestrator/.env     DISCORD_BOT_TOKEN, DISCORD_OPS_CHANNEL, DISCORD_ALLOWED_USERS
  (채널ID는 config.yaml의 ${DISCORD_*_CHANNEL} 가 자동 참조)

── 컨테이너 기동 ──
  cd docker && docker compose up -d --build
  docker compose exec hermes hermes -p dev-orchestrator gateway restart
  docker compose exec hermes hermes -p invest-orchestrator gateway restart
  docker compose exec hermes hermes -p ops-orchestrator gateway restart

상세 절차는 hermes-setup-guide.md / hermes-setup-todo.md 참조.
GUIDE
echo "── install 완료 ──"

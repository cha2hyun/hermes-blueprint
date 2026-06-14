# Hermes 구축 TODO (에이전트 실행용)

> 이 문서는 호스트 코딩 에이전트(Claude Code/Codex)가 `hermes-setup-guide.md`를 설계 문서 삼아
> 단계별로 실행하기 위한 체크리스트다. 위에서부터 순서대로 진행하고, 각 Phase의 **완료 검증을 통과해야 다음 Phase로** 넘어간다.
>
> 표기: 🤖 에이전트 실행 / 🧑 사람만 가능 (에이전트는 안내 후 대기) / 🔐 에이전트가 제안하되 사람 승인 후 실행
> 에이전트 공통 규칙: 루트 AGENTS.md 준수 — `.env`/`auth.json` 접근 금지, 상태 변경 명령은 승인 대기.
> 완료한 항목은 `[x]`로 갱신하고, 문제 발생 시 항목 아래에 `> ⚠️ 메모`를 남긴다.

---

## Phase 0 — 사전 준비 (사람 작업 위주)

목표: 에이전트가 일할 수 있는 외부 조건 확보. 에이전트는 누락 항목을 점검·안내한다.

- [x] 🧑 Docker Desktop for Mac 설치 및 실행 확인
  > ✅ 2026-06-12 데몬 응답 확인 (Docker 29.4.0, 컨테이너 0개)
- [x] 🧑 Discord 개인 서버 생성
  > ✅ 2026-06-13 생성 완료 — 서버 ID `<DISCORD_SERVER_ID>`
- [ ] 🧑 Discord Developer Portal에서 봇 3개 생성(개발봇/투자봇/운영봇), 토큰 3개 확보, 서버에 초대
  > 📋 2026-06-13 진행: 봇 1/3 `hermes_dev`(=개발봇, App ID <DEV_APP_ID>) 생성·서버 초대·토큰을 dev-orchestrator .env에 등록 완료
  > ⚠️ hermes_dev 최초 토큰이 채팅에 노출 → 사용자가 Reset 후 클립보드 방식으로 재등록함. Message Content Intent ON 확인됨
  > ✅ 2026-06-13 hermes_dev 멘션 테스트 통과 — Discord 연결 + opus-4.8 응답 + SOUL.md 정체성 일치. 봇이 home channel 설정(/sethome)을 요청한 상태 — #agents-feed 생성 후 거기서 실행 예정
  > 📋 2026-06-13 봇 2/3 `hermes_invest`(App ID <INVEST_APP_ID>) 생성, 토큰 클립보드 등록(미노출), 전원 허용 적용, 게이트웨이 연결 확인(`hermes_invest#1409`). 전용 채널 `#hermes_invest`(ID <INVEST_CHANNEL_ID>) 멘션-프리 설정 완료
  > ✅ 2026-06-13 hermes_invest 사용자 확인 완료 (초대·Intent·테스트·/sethome)
  > 📋 채널 모델 변경(사용자 결정): 공용 명령 채널(#agents-ops) 대신 **봇별 전용 채널**(#hermes_dev 등, `discord.free_response_channels`로 멘션-프리) + 공용 #agents_feed(home). 문서의 채널 구성 설명은 Phase 5 마무리 때 일괄 갱신 예정
- [ ] 🧑 채널 2개 생성: `#agents-feed`, `#agents-ops`
  > 📋 2026-06-13 진행: `#agents_feed` 생성 완료 (실제 채널명은 언더스코어, ID <AGENTS_FEED_CHANNEL_ID>) + hermes_dev가 `/sethome`으로 home channel 지정 완료. `#agents_ops` 생성 남음
  > ⚠️ 2026-06-12 사용자 결정: 메시징 항목 보류 → 06-13 텔레그램으로 변경했다가 **같은 날 사용자 결정으로 Discord 원안 복귀** (텔레그램 흔적은 문서·템플릿에서 제거됨). Phase 5 게이트웨이 연결 전까지 완료 필요. Phase 1~4는 메시징 무관이라 선진행함
- [x] 🧑 LLM API 키 발급 (Anthropic은 Console **API 키** — 구독 OAuth 아님)
  > ✅ 2026-06-12 사용자 확인: 키 준비됨 (아직 어디에도 미입력)
- [x] 🧑 (권장) 호스트에 Claude Code 설치 — 이 TODO를 실행할 주체
  > ✅ 이 세션이 호스트 Claude Code (Fable 5)
- [x] 🤖 점검: `docker --version`, `git --version` 정상 출력 확인
  > ✅ Docker 29.4.0 / git 2.50.1 (Apple Git-155)

**완료 검증**: Docker 데몬 응답 + 토큰 3개·API 키가 사람 손에 준비됨 (아직 어디에도 입력하지 않음)

---

## Phase 1 — 폴더 구조 + 모노레포 + 규칙 문서

목표: 3분할 구조(.hermes / workspace / repos)와 4층 규칙 문서의 뼈대.

- [x] 🤖 디렉터리 생성 (가이드 §2의 mkdir 블록 그대로 실행, `chmod 700 ~/hermes/.hermes` 포함)
- [x] 🤖 `~/hermes`에서 `git init`
- [x] 🤖 `.gitignore` 작성 (가이드 §2 내용: `.hermes/`, `**/worktrees/`, `**/node_modules/`, `workspace/invest/data/`, `*.log`)
- [x] 🤖 루트 `AGENTS.md` 작성 (가이드 §8 템플릿 그대로) + `CLAUDE.md` 작성 ("AGENTS.md를 읽어라" 1줄)
- [x] 🤖 루트 `README.md` 작성 (구조 요약 + "설계는 hermes-setup-guide.md, 진행은 hermes-setup-todo.md" 안내)
- [x] 🤖 `hermes-setup-guide.md`, `hermes-setup-todo.md`(이 파일)를 루트에 배치
- [x] 🤖 `workspace/GLOBAL.md` 작성: 커밋 컨벤션 `[도메인/프로젝트] 메시지`, worktree 네이밍 `task-<ID>-<요약>`, 경로 규칙(/repos 코드, /workspace 산출물)
- [x] 🤖 도메인 AGENTS.md 3개 작성 (dev/invest/ops — 첫 줄 "../GLOBAL.md를 먼저 읽는다" + 도메인별 골격. 세부 규칙은 Phase 6 이후 운영하며 채움)
- [x] 🤖 `workspace/dev/brief.md` 골격 생성 (사람이 내용 채울 자리 표시)

**완료 검증** 🤖:
- `tree -a -L 3 ~/hermes` (또는 find) 출력이 가이드 §2 트리와 일치
- `git check-ignore ~/hermes/.hermes` 가 경로를 출력 (ignore 작동 확인)
> ✅ 2026-06-12 검증 통과: find 트리 = §2 구조 일치, check-ignore `.hermes` 출력 확인, `.hermes` 권한 drwx------(700)

---

## Phase 2 — Docker 환경 확정·기동

목표: 컨테이너가 뜨고, 3개 마운트가 연결되고, hermes CLI가 응답.

- [x] 🤖 **조사**: Hermes 공식 문서에서 현재 버전의 권장 설치 방식 확인 (공식 Docker 이미지 존재 여부 / 없으면 베이스 이미지 + 설치 명령). 결과를 이 항목 아래 메모로 기록
  > 📋 2026-06-12 조사 결과:
  > - **공식 이미지 있음**: Docker Hub `nousresearch/hermes-agent`. 태그는 날짜 기반 — 최신 안정 `v2026.6.5` (= GitHub release v0.16.0 "The Surface Release", 2026-06-05). `latest`/`main`은 무빙 태그라 사용 금지
  > - 이미지 구조: debian 13.4 + Python venv(`/opt/hermes/.venv`) + Node 22/npm + ripgrep 내장. s6-overlay가 PID 1, entrypoint 래퍼가 인자를 hermes CLI로 전달 (첫 인자가 실행파일이면 그대로 실행 — `sleep`/`bash` 가능). 기본 실행 사용자 `hermes`(UID/GID 10000, `HERMES_UID`/`HERMES_GID`로 변경), `HOME=HERMES_HOME=/opt/data`
  > - ⚠️ **가이드 보정**: 상태 마운트는 `/root/.hermes`가 아니라 **`/opt/data`** (공식 VOLUME). compose에서 `~/hermes/.hermes:/opt/data`로 매핑 → 프로파일은 호스트 `.hermes/profiles/`에 그대로 대응
  > - 공식 compose는 gateway(`gateway run`)·dashboard 2서비스 + `network_mode: host`. 우리는 설계대로 브리지 + `127.0.0.1:9119:9119` 유지 → **대시보드는 컨테이너 안에서 `--host 0.0.0.0`으로 기동**해야 포트포워딩이 닿음 (호스트 노출은 여전히 127.0.0.1 한정 — Phase 5에서 적용)
  > - Phase 2~4 컨테이너 커맨드는 `sleep infinity` (CLI 상주용). 게이트웨이 기동 방식은 Phase 5 조사로 확정
  > - Claude Code는 npm 최신 `2.1.175`로 버전 핀
- [x] 🤖 `docker/Dockerfile` 작성 — 조사 결과 반영, 버전 핀 고정, git·ripgrep 설치, Claude Code 설치(`npm install -g @anthropic-ai/claude-code@<버전>`), `COPY .env`/`ENV 키` 부재 확인
  > ✅ `nousresearch/hermes-agent:v2026.6.5` 핀 + git 설치(ripgrep은 베이스 내장) + claude-code@2.1.175 + venv PATH. 시크릿 관련 라인 없음
- [x] 🤖 `docker/compose.yml` 작성 — 마운트 3개(.hermes/workspace/repos), 대시보드 포트(`127.0.0.1:9119:9119` — 반드시 127.0.0.1 바인딩), `restart: unless-stopped`, 리소스 리밋(cpus 4 / mem 8g)
  > ✅ 상태 마운트는 조사 결과대로 `/opt/data`. 커맨드는 임시 `sleep infinity` (Phase 5에서 게이트웨이 방식 확정 후 교체)
- [x] 🔐 `docker compose up -d --build` (첫 빌드)
  > ✅ 2026-06-12 사용자 승인 후 실행. my-hermes:1.0 빌드, 컨테이너 `hermes` Up
- [x] 🤖 검증: `docker compose exec hermes hermes --version` 정상 출력
  > ✅ `Hermes Agent v0.16.0 (2026.6.5)` — 가이드 기준 버전과 일치
- [x] 🤖 검증: 컨테이너 안에서 `/opt/data`(≒가이드의 /root/.hermes — 조사 메모 참조), `/workspace`, `/repos` 마운트 확인 (`ls` 3회)
  > ✅ 3개 마운트 정상. 첫 기동 시 hermes가 /opt/data에 기본 상태(config.yaml, SOUL.md, memories/ sessions/ 등) 생성함 — 호스트 `.hermes/`에 반영 확인
- [x] 🤖 검증: `docker compose exec hermes claude --version` (coder의 실행 엔진 준비 확인)
  > ✅ claude 2.1.175 + git 2.47.3 (컨테이너 내)
- [x] 🤖 첫 커밋: `[infra] 폴더 구조 + Docker 환경` (커밋 전 `git check-ignore .hermes` 재확인)
  > ✅ c558952, 13파일. `.hermes`/`.claude` 미포함 확인. ⚠️ 메모: `.gitignore`에 `.claude/`(호스트 에이전트 로컬 설정) 추가, git 신원은 저장소 로컬로 `<초기 git author>` 설정 — 변경 원하면 `git config user.name/email`

**완료 검증**: 위 세 검증 명령 모두 통과 + 첫 커밋 존재
> ✅ 2026-06-12 Phase 2 완료

---

## Phase 3 — 프로파일 생성 + 시크릿 배치

목표: 프로파일 10개와 인증 정보. **시크릿 입력만 사람 손으로.**

- [x] 🔐 프로파일 10개 생성 (가이드 §4의 명령 블록 그대로, description 포함 — `docker compose exec` 경유)
  > ✅ 2026-06-12 사용자 승인 후 생성. 하이픈 포함 이름 허용 확인. 첫 기동 시 자동 생성된 `default` 프로파일이 별도로 존재 (미사용 — 그대로 둠)
  > 📋 2026-06-13 도메인 네이밍 변경(사용자 결정): **webdev → dev** (`dev / invest / ops` 계열 통일). `hermes profile rename web-orchestrator dev-orchestrator` + workspace/repos 폴더 mv + tenant·cwd·경로·문서 일괄 치환. 이 파일의 06-12 이력 메모에 등장하는 dev-* 표기는 당시엔 web-* 이름이었음
- [x] 🤖 검증: `hermes profile list` 출력에 10개 전부 존재
  > ✅ 10개 + default 확인
- [ ] 🧑 `.env` 작성 — 에이전트가 **키 이름만 적힌 템플릿**을 각 프로파일에 생성해주고, 값은 사람이 직접 붙여넣기:
  - 오케스트레이터 3개: 각자의 Discord 봇 토큰 + LLM API 키
  - coder: LLM API 키 + `ANTHROPIC_API_KEY` (Claude Code용)
  - 나머지 워커: LLM API 키
  > 📋 템플릿 10개 생성 완료 (v0.16 실제 키 이름으로: 오케스트레이터는 `DISCORD_BOT_TOKEN`, `DISCORD_ALLOWED_USERS` 포함). coder는 Claude Code도 같은 `ANTHROPIC_API_KEY`를 쓰므로 키 1개로 충분
  > ✅ 2026-06-12 ANTHROPIC_API_KEY 10개 파일 입력 완료 — 사용자 클립보드 → 변수 경유 등록 (값 미노출, 형태 sk-ant-* 검증, 600 권한 유지)
  > 📋 2026-06-13 플랫폼이 텔레그램으로 갔다가 Discord로 복귀 — .env 템플릿 키도 `DISCORD_*`로 원복 (값 미입력 상태에서의 치환이라 무손실)
  > ⚠️ 남은 사람 작업: Discord 봇 토큰·본인 사용자 ID 입력 (오케스트레이터 3개 .env — Phase 5 게이트웨이 연결 전까지)
- [x] 🤖 권한 정리: `chmod 600` 일괄 적용 (값은 읽지 않고 권한만 변경)
  > ✅ 10개 전부 -rw-------
- [x] 🤖 검증: `git check-ignore .hermes/profiles/*/.env` 전부 통과
  > ✅ 10개 경로 전부 출력 (ignore 작동)

**완료 검증**: profile list 10개 + .env 600 권한 + ignore 통과. (에이전트는 .env 내용을 한 번도 출력하지 않았어야 함)

---

## Phase 4 — SOUL.md / config.yaml 작성

목표: 가이드 §5의 베스트케이스를 실제 파일로. 에이전트가 쓰고 사람이 검토.

- [x] 🤖 오케스트레이터 SOUL.md 3개 작성 — 가이드 §5-3 dev-orchestrator 전문을 기반으로 invest/ops 변형 (팀 구성·tenant·범위 밖 안내처만 치환)
  > ✅ web=가이드 전문 그대로 / invest=팀·tenant 치환 + "매수/매도 지시 금지" 추가 / ops=tenant는 호출자 기준 규칙 + 예약 칸반 태스크 규칙
- [x] 🤖 워커 SOUL.md 7개 작성 — coder(실행 전략 + Claude Code 호출 규칙 + 핸드오프 계약), ops-worker(가이드 전문), planner/designer/qa/analyst/risk-checker(coder 골격에서 역할·계약 치환)
  > ✅ coder·ops-worker는 가이드 전문 (ops-worker에 "push 정책은 ops/AGENTS.md 참조 — 현재 금지" 1줄 추가). 나머지 5개는 정체성/작업 규칙/금지/핸드오프 계약 구조로 작성
  > ⚠️ 발견: 컨테이너 s6가 프로파일별 게이트웨이 데몬을 자동 기동 중 → 기동 시 SOUL.md 자가 복구(기본 내용 재생성)가 있어 삭제→생성 대신 **덮어쓰기**로 작성함. 새 SOUL/config 적용은 데몬 재시작 필요 (Phase 5에서)
- [x] 🤖 config.yaml 10개 작성 — §5-1 모델 차등 + fallback_model, §5-2 toolset·command_allowlist·cwd
  > ✅ v0.16 확인 결과 프로파일별 config.yaml은 코드 기본값 위 병합되는 독립 파일. 최소 오버레이로 작성 + `_config_version: 27`. 모델: 오케스트레이터=opus-4.8 / 나머지=sonnet-4.6 (모델 카탈로그 ID 검증함)
  > ⚠️ fallback_model 미설정: 지원 프로바이더(openrouter/zai/kimi 등)용 제2 키가 없음. 단일 Anthropic 키 상태에선 실효 낮아 보류 — OpenRouter 키 확보 시 활성화 권장 (무인 운영 안정성 ↑)
  > ⚠️ 가이드 대비 의도적 편차 3건(리뷰 시 확인): ① invest-orchestrator만 web 유지 (판단 순서 1 "직접 조회 응답" 가능하게) ② planner/designer/qa/risk-checker는 file 쓰기 유지 (specs/design/qa-reports 산출물 작성에 필요 — 행동 제한은 SOUL.md 금지 조항으로) ③ ops-worker allowlist에 git push 미포함 (초기 push 보류 정책의 기계적 강제)
- [x] 🤖 각 오케스트레이터에 `hermes config set kanban.orchestrator_profile <이름>` (조회성 set이지만 첫 적용이므로 🔐 권장)
  > ✅ CLI 대신 config.yaml 직접 작성에 포함 (§8 "사람 감독 하 파일 편집" 경로). 3개 모두 자기 이름으로 설정
- [x] 🤖 검증: `docker compose exec hermes hermes doctor` (또는 동급 진단) 통과 — yaml 깨짐 안전망
  > ✅ doctor: 10개 프로파일 전부 의도한 모델로 정상 파싱, config version 27 ✓. 남은 지적 3건은 무해(컨테이너 심볼릭링크 표시 / 비활성화된 browser의 npm 취약점 / API 키 미입력—예정된 상태). toolset 차등 적용도 스팟 체크 통과 (dev-orchestrator: terminal·file·web 비활성 / coder: terminal·file 활성, web 비활성)
- [x] 🧑 **리뷰 게이트**: SOUL.md 10개를 사람이 통독·수정 (특히 금지 조항과 핸드오프 계약)
  > ✅ 2026-06-12 사용자 리뷰 완료 확인 (의도적 편차 3건 포함)
- [x] 🤖 커밋: 없음 (.hermes는 git 밖) — 대신 진행 메모를 이 파일에 기록

**완료 검증**: doctor 통과 + 사람 리뷰 완료 표시
> ✅ 2026-06-12 Phase 4 완료

---

## Phase 5 — 게이트웨이 기동 (Discord 연결)

목표: 봇 3개가 Discord에 온라인, 멘션 응답 확인.

- [x] 🤖 **조사**: 현재 버전의 멀티 게이트웨이 기동 방식 확인 (프로파일별 `hermes gateway` 실행 방법, 데몬 관리) → 메모 기록
  > 📋 2026-06-12 조사 결과 (v2026.6.5 Docker 이미지):
  > - **멀티 게이트웨이는 컨테이너 내장 기능**: s6 수퍼바이저가 프로파일별 `gateway-<name>` 서비스를 동적 관리. profile create 시 자동 등록·기동, 부트 시 리컨실러(cont-init.d/02)가 **"마지막 상태 running"인 게이트웨이만** 재기동 → stop은 재시작을 넘어 영속
  > - 제어 명령: `hermes -p <name> gateway start|stop|restart|status`, 전체는 `hermes gateway list` / `stop --all` (s6 경유라 깔끔히 want-down)
  > - 현재 프로파일 생성 부산물로 **11개 전부(default+10) 게이트웨이 기동 중** (토큰 없어 유휴, 각 ~110MB) → 워커 7 + default 8개 stop, 오케스트레이터 3개만 유지 필요 (디스패처는 오케스트레이터 게이트웨이 안에서 동작, 워커는 디스패처가 일회성 프로세스로 실행 — 워커 상주 불필요)
  > - .env(토큰)/SOUL/config 변경 반영 = `gateway restart`
  > - **대시보드**: s6 상주 슬롯은 `HERMES_DASHBOARD=1` env일 때만 — 우리는 가이드 원칙(필요시 기동)대로 env 미설정 유지, 온디맨드 실행: `docker compose exec hermes hermes dashboard --host 0.0.0.0 --no-open --insecure` (컨테이너 안 0.0.0.0이지만 호스트 노출은 compose의 `127.0.0.1:9119` 매핑뿐. `--insecure`=무인증이므로 보고 나면 Ctrl-C로 종료. 인증 원하면 dashboard.basic_auth 설정 가능)
- [ ] 🔐 게이트웨이 3개 기동 (web/invest/ops 오케스트레이터)
  > 📋 2026-06-12 선행 정리(사용자 승인): 워커 7개 + default 게이트웨이 stop (영속 — 부트 리컨실러가 재기동 안 함). 오케스트레이터 3개는 이미 실행 중 (토큰 없어 메시징 미연결 유휴). 토큰 입력 후 `hermes -p <name> gateway restart` 3회만 하면 됨
  > ⚠️ `hermes gateway list`가 exec(root) 컨텍스트에서 전부 "not running"으로 표시되는 감지 결함 있음 — 실상태는 `ps aux | grep 'gateway run'`으로 확인할 것
  > ⚠️ 2026-06-13 발견: **컨테이너 재시작 시 게이트웨이 자동 복구 안 됨** — 종료 과정에서 s6가 게이트웨이를 내리며 상태가 "stopped"로 기록되어, 부트 리컨실러("마지막 상태 running만 기동")가 제외함. 컨테이너/맥 재시작 후에는 `hermes -p <오케스트레이터> gateway start` 3회 필요. Phase 5에서 자동화 방안(예: compose command를 gateway run으로 교체) 검토
  > 📋 2026-06-13 프로파일 rename(web→dev-orchestrator) 후 s6 슬롯이 구 이름으로 남는 문제 → 컨테이너 재시작으로 리컨실 완료. 현재 dev/invest/ops 3개 실행 중 확인
- [ ] 🤖 검증: 게이트웨이 상태/리스트 명령으로 3개 모두 running
- [ ] 🔐 웹 대시보드 기동(`hermes dashboard`) → 🧑 http://127.0.0.1:9119 접속, 게이트웨이 3개 상태 화면 확인 (확인 후 종료해도 무방)
  > 📋 2026-06-13 선행 테스트: 온디맨드 기동(`--host 0.0.0.0 --no-open --insecure`) → 호스트에서 HTTP 200, 포트 노출은 `127.0.0.1:9119`뿐(docker port로 확인). 사용자 화면 확인 대기 중
- [ ] 🧑 사용자 allowlist 값 입력: 각 오케스트레이터 .env의 `DISCORD_ALLOWED_USERS`에 본인 Discord 사용자 ID(쉼표 구분 숫자) — v0.16 소스에서 형식 확인됨. 채널 단위 제한이 더 필요하면 config `discord.allowed_channels`
- [x] 🧑 Discord에서 확인: 봇 3개 온라인 표시
  > ✅ 2026-06-13 hermes_dev#7493 / hermes_invest#1409 / hermes_ops#7286 — 3개 모두 `✓ discord connected` (게이트웨이 로그)
- [ ] 🧑 각 봇 전용 채널에서 응답 확인 (채널 모델 변경: #agents-ops 공용 방 → 봇별 멘션-프리 채널)
  > ✅ dev: 멘션 테스트 + 멘션-프리 채널 + 크론 1회전 통과 / ✅ invest: 사용자 확인 완료 / ✅ ops: 토큰 등록·연결(hermes_ops#7286)·멘션-프리 채널 설정 완료
  > 📋 2026-06-13 `auto_thread: false`를 3개 오케스트레이터 config에 적용 + 재시작 — 이유: ① 멘션 시 자동 스레드 생성 때문에 `/sethome`이 채널이 아닌 스레드로 잡히는 문제 ② 봇별 전용 채널엔 봇 1개뿐이라 스레드 불필요. 응답이 채널에 직접 달림
  > 📋 채널 응답 규칙 정리(사용자 우려 해소): `free_response_channels`(멘션 불필요)와 `auto_thread`(스레드 생성)는 별개. agents_feed는 어느 봇의 free_response도 아니라 **멘션 필수** → 멘션한 봇만 응답("모든 봇 동시 응답" 불가). 전용 채널만 free_response이며 채널당 봇 1개라 충돌 없음. 봇간 무반응은 `DISCORD_ALLOW_BOTS=none` 기본값으로 보장
  > ✅ 2026-06-13 ops 무응답 원인 규명·해결: home이 죽은 스레드 ID(.env DISCORD_HOME_CHANNEL)로 박혀 멘션 응답이 그 스레드로 배달되다 404. auto_thread off + 메인 채널에서 /sethome 재실행으로 home 교체 → 3봇 모두 shutdown 알림이 #agents_feed에 정상 도착 확인 (home 배달 작동)
  > 📋 home channel(#agents_feed) 자동 수신 메시지 4종 (소스 확인): ① 게이트웨이 라이프사이클(종료/재시작/복귀) ② 크론 결과(배달처가 origin 아닐 때) ③ 크로스플랫폼/배달처 미지정 ④ 백그라운드 작업 알림. 라이프사이클 알림은 `discord.gateway_restart_notification: false`로 끌 수 있음 (구축 중 재시작 잦아 자주 보이는 것 — 운영 시 조용해짐)
  > ⏳ 남은 사람 작업: #agents_feed 음소거
- [x] 🧑 사용자 allowlist 설정 (본인 Discord ID만 명령 허용) — 방식은 에이전트가 문서에서 조사해 안내 🤖
  > ⚠️ 2026-06-13 사용자 결정으로 **설계 변경: allowlist 잠금 대신 전원 허용** — 비공개 서버 + 추후 지인 초대 시 봇 사용 허용 목적. v0.16은 allowlist 전무 시 기본 전원 거부라 `GATEWAY_ALLOW_ALL_USERS=true`를 프로파일 .env에 명시 (dev 적용 완료, invest/ops도 토큰 입력 시 동일 적용). 가이드 §10의 해당 항목은 "의도된 예외"로 처리 — 서버 초대 = 봇 명령 권한 공유임을 인지한 결정
  > 📋 참고: 본인 Discord ID `<YOUR_DISCORD_USER_ID>` (로그에서 확인) — 잠금으로 회귀 시 `DISCORD_ALLOWED_USERS`에 사용
- [ ] 🧑 봇이 봇에게 반응하지 않는지 확인 (봇 응답 메시지에 다른 봇이 반응 안 함)
- [x] 🧑 `#agents-feed` 음소거 + 멘션만 알림 설정
  > ✅ 2026-06-14 사용자가 #agents_feed 음소거 완료 → Phase 5 사람 항목 전부 종료

**완료 검증**: 봇 3개 멘션 응답 + allowlist 적용 + 봇 상호 무반응

---

## Phase 6 — 스모크 테스트 (도메인별 1회전)

목표: "사람 → 봇 → 보드 → 디스패처 → 워커 → 핸드오프 → 보고"의 전체 루프 검증.

> 🚧 **블로커 (2026-06-13, 사용자 결정으로 해결 보류)**: 컨테이너 안에서 git이 작동하지 않음.
> 원인: 호스트 `~/hermes` 전체가 git 저장소(`.git`은 루트)인데, 컨테이너엔 `/workspace`·`/repos`·`/opt/data`만 분리 마운트되어 `.git`이 안 보임 (`git status` → fatal: not a git repository).
> **막히는 것**: coder의 "완료=커밋", worktree-per-task(`/workspace/dev/worktrees/`), ops-worker 자동 분할 커밋, Phase 7의 ops 커밋 크론.
> **되는 것**: 워커의 파일 생성(코드·명세·리포트는 마운트로 호스트에 그대로 반영), 오케스트레이터 라우팅·분해, 봇 응답, 보고성 크론, invest 분석.
> **해결 후보**(논의만 함, 미결): ① /repos 컨테이너 내 독립 git ② ~/hermes 루트 통째 마운트(보안 트레이드오프) ③ `.hermes` 제외하고 `.git`+workspace+repos 마운트 + 프로파일 파일 경로 샌드박스 확인. 사용자는 ②번에 관심 + "특정 프로파일만 권한"을 원했으나 단일 컨테이너 마운트로는 프로파일별 분리 불가 → hermes 도구 권한으로 부분 통제만 가능. **재개 시 §2~3 마운트 설계부터 재검토 필요.**
> 따라서 dev 코딩 풀루프(커밋 포함)는 git 해결 전까지 부분 검증만 가능.

> ⚠️ 2026-06-13 스모크 테스트 1차에서 발견·수정한 **Phase 4 누락**: 오케스트레이터 config에 `toolsets: [hermes-cli, kanban]`의 **kanban이 빠져 있어** 봇이 태스크 배정 도구(kanban_create 등)를 못 가져 분해 불가였음. (봇이 스스로 정확히 진단해 "kanban 툴셋 활성화 필요"라고 안내함.) kanban은 check_fn-gated 툴셋이라 `_profile_has_kanban_toolset()`이 config.yaml의 `toolsets`에 "kanban" 문자열이 있는지로 게이트 → **config.yaml의 toolsets에 직접 추가가 정답**. `hermes tools enable kanban`은 "Unknown toolset" 에러(configurable universe 밖) + 부작용으로 config를 전체 디폴트로 팽창시킴(커스텀 값은 보존). dev config가 그 부작용으로 514줄로 팽창됨 — 기능 정상, 나중에 최소 오버레이로 정리 가능. 3개 모두 `'kanban' in toolsets == True` 확인 + 재시작 완료.
> 📌 **가이드 §5-2 보강 필요**: "오케스트레이터=kanban toolset 허용"을 config.yaml `toolsets`에 `kanban` 명시로 구체화 (이번 누락의 근본 원인이 가이드의 추상적 표현).
> ✅ **스모크 테스트 1회전 결과 (2026-06-13, dev 도메인)** — 핵심 협업 루프 검증 성공:
>  - 분해: planner→designer→coder(standard)→qa 의존성 그래프, 전부 `[dev]` tenant, 난이도 등급 부여 — SOUL.md 규칙대로
>  - 산출물: 명세 `specs/t_fe0ecf5e-gugudan-page.md`, 설계 `design/t_d2dc073e-gugudan-ui-design.md` (태스크ID 네이밍 ✓)
>  - 디스패처: ready 태스크 자동 클레임 → coder 독립 프로세스(`work kanban task t_daf1c47a`) 실행
>  - coder: 명세·설계 read → Claude Code 위임 실패하자 **직접 구현으로 폴백** → 383줄 구구단 HTML 생성(designer CSS변수 반영). 적응력 양호
>
> 🚧 **드러난 블로커 4개 (무인 운영 전 해결 필요)** — Phase 6이 노출시킨 핵심 수확:
>  1. **git 미작동** (기존, 보류) — 커밋·worktree 불가
>  2. **Claude Code 인증 안 됨**: coder가 `claude` 위임 시 `Not logged in · Please run /login`. 컨테이너 claude CLI에 ANTHROPIC_API_KEY가 안 닿음 (config `terminal.env_passthrough: []` 비어있음 의심). → coder의 standard/heavy 위임 전략이 무력, 직접 구현 폴백으로만 동작. **해결: coder config terminal.env_passthrough에 ANTHROPIC_API_KEY 추가 또는 claude 호출 방식 점검**
>  3. **approval 모드 manual**: 무인 워커의 terminal/execute_code 명령이 `pending_approval`로 멈춤 → coder 태스크가 결국 **blocked**로 종료(검증 단계 못 넘김). command_allowlist(node/python3 포함)가 워커 컨텍스트에서 적용 안 되는 것으로 보임. **해결: approvals.cron_mode/무인 워커용 자동승인 또는 allowlist 동작 점검 필요**
>  4. **워커 산출물 경로 불일치**: coder가 `/opt/data/kanban/workspaces/t_daf1c47a/gugudan.html`에 작성 — GLOBAL.md 규칙(`/repos/dev/<프로젝트>`)·worktree 설계(`/workspace/dev/worktrees/`)와 다름. 게다가 이 위치는 `.hermes` 볼륨 안이라 **git에도, 호스트 workspace/repos에도 안 나타남**. hermes kanban-worker의 기본 워크스페이스 동작과 우리 경로 설계의 충돌 — git 구조(블로커1)와 함께 재설계 필요
>
> → 결론: "사람→봇→보드→디스패처→워커→산출물" 루프는 **작동 확인**. 단 coder의 완결(커밋·검증·올바른 경로 저장)은 블로커 2/3/4 해결 후 가능. 이들은 §2~3 마운트·§5 워커 config·§6-4 위임 인증과 얽혀 있어 묶어서 재검토.
>
> ✅ **블로커 2·3 해결 (2026-06-13)**:
>  - 2(claude 인증): coder config `terminal.env_passthrough: [ANTHROPIC_API_KEY]` → claude CLI에 키 전달
>  - 3(approval): coder·ops-worker config `approvals.mode: "off"` (사용자 결정 — 무인 워커 전자동, 컨테이너 샌드박스+cwd가 안전망). ⚠️ YAML에서 `off`는 boolean이 되므로 **반드시 따옴표** (`"off"`); 로드값 `'off'` 문자열 확인. 워커는 디스패처가 매번 새 프로세스로 띄우므로 게이트웨이 재시작 불필요 — 다음 태스크부터 반영.
> 🚧 **블로커 4 보류 (git과 묶어 재설계)**: workspace 종류는 태스크 속성(`scratch`/`worktree`/`dir:<path>`). 보드 `set-default-workdir` 또는 태스크별 `--workspace dir:<path>`로 교정 가능하나, **단일 보드 + 멀티 도메인**이라 보드 기본값 하나로 dev/invest/ops 경로를 못 나눔 + git 구조(블로커1)와 얽힘 → §2~3 마운트 재설계 시 함께. 재테스트해도 산출물은 scratch(`/opt/data/kanban/workspaces/`)에 남아 호스트 미표시.
> ⏳ 재테스트: blocked된 t_daf1c47a 재개 또는 #hermes_dev 재요청 → coder가 claude 위임 + 검증 명령 자동실행으로 **완주**하는지 확인 (경로는 블로커4로 여전히 scratch)
>
> ✅ **블로커 4 해결 (2026-06-13, 사용자 지적)**: 산출물이 `.hermes/kanban/workspaces/`(scratch 기본값)에 들어간 건 규칙 위반(`.hermes`=사용자·워커 미접근 구역, 코드는 `/repos/dev`). kanban_create 도구가 `workspace_kind`("scratch"/"dir"/"worktree")·`workspace_path`(절대경로)를 받음을 확인 → **dev-orchestrator SOUL.md 분해 규칙에 "코드 생성 구현 태스크는 workspace_kind='dir', workspace_path='/repos/dev/<프로젝트명>'으로 생성, scratch·worktree 금지" 추가** + 재시작 완료. 단일 보드+멀티도메인이라 보드 기본값(set-default-workdir) 대신 오케스트레이터가 태스크별로 지정하는 방식 채택. (planner/designer/qa는 workspace 지정 없이 /workspace/dev 역할폴더에 직접 쓰는 게 이미 정상 작동 — 변경 불필요.)
> ⚠️ git 커밋(블로커1)은 여전히 별개로 보류 — dir:/repos/dev로 위치는 교정되나 컨테이너에 .git 없어 coder의 "완료=커밋"은 미해결.
> 🧹 기존 잘못된 결과물 정리 대상: dev 보드 태스크 4개(t_fe0ecf5e/t_d2dc073e/t_daf1c47a/t_1c87f5f2 — scratch로 생성됨) + `.hermes/kanban/workspaces/t_daf1c47a/gugudan.html`. 새 요청 시 올바른 위치에 재생성되므로 정리 후 재요청 권장.
>
> ⚠️ **블로커 4 수정 1차 실패 → 2차 보강 (2026-06-13)**: dev-orchestrator SOUL에 workspace 규칙을 박고 재시작했으나, **재요청한 새 파이프라인(t_f6db4088 등)도 여전히 scratch로 생성됨** — 오케스트레이터 LLM이 kanban_create에 `workspace_kind="dir"`를 안 넣음(SOUL 규칙 미준수, LLM 변동성). → **2차 방어로 coder SOUL.md에 "모든 코드는 /repos/dev/<프로젝트>에 절대경로로 작성, scratch에 두지 않는다" 직접 명시** (coder는 planner가 specs/에 쓰듯 자기 작업 규칙은 따를 가능성 ↑). 이전 4개 아카이브 완료(`kanban archive`). 
> 🔎 **재검증 필요 + 미해결 가능성**: 두 SOUL 규칙 모두 LLM 판단 의존이라 100% 보장 아님. 다음 재요청에서 coder가 /repos/dev에 쓰는지 확인 → 또 실패하면 **시스템 레벨 강제** 필요(보드 `set-default-workdir`, 또는 PreToolUse 훅으로 scratch 경로 차단). 단일보드+멀티도메인이라 보드 기본값은 부작용 검토 후.
> ❌ **2~3차 재시도도 scratch (2026-06-13)**: SOUL 강화(orchestrator dir 지정 + coder 절대경로) 2회 다 무시됨 — LLM이 SOUL의 workspace 규칙을 안정적으로 안 따름. 그리고 **`set-default-workdir`는 scratch에 무효 확인**(kanban_db.py:2189 — default_workdir는 workspace_kind이 dir/worktree일 때만 상속; scratch는 #28818 안전가드로 사용자 소스트리 상속 금지). 즉 orchestrator가 dir 명시 안 하면 무조건 `.hermes` scratch.
>
> ✅ **git 워크플로 재정의 (2026-06-13, 사용자 결정 — 블로커1 우회)**:
>  - hermes 워커는 `/repos/dev/<프로젝트>`가 **클론된 독립 레포(자체 .git)일 때만** 그 레포 안에서 커밋/push (ops-worker). 그 .git은 repos 마운트 안이라 컨테이너에서 작동 → 블로커1(monorepo .git 부재) 우회.
>  - monorepo(~/hermes) 전체 git은 **hermes 밖 외부 에이전트(호스트 Claude Code)가 관리**. hermes는 서브모듈/클론레포 단위로만 git.
>  - → 남은 건 블로커4(코드가 scratch 아닌 /repos/dev에 생기게)뿐. git 자체는 더 이상 블로커 아님.
>
> 🔬 **블로커4 근본 원인 완전 규명 (2026-06-13)**:
>  - kanban-worker 스킬(`/opt/hermes/skills/devops/kanban-worker/SKILL.md`)이 워커에게 **"$HERMES_KANBAN_WORKSPACE 밖 파일 수정 금지"**를 명시 → coder는 스킬을 따라 workspace 안에서만 작업. coder SOUL의 "절대경로 /repos/dev" 규칙은 이 스킬과 **충돌**해 무력했음(coder 잘못 아님).
>  - 따라서 유일한 해결 = **태스크의 workspace_kind를 dir, workspace_path를 /repos/dev/<프로젝트>로** 만드는 것. 그러면 $HERMES_KANBAN_WORKSPACE가 /repos/dev가 되어 스킬 규칙을 지키면서 올바른 위치에 씀.
>  - 그런데 workspace 지정은 **오케스트레이터/decomposer(LLM)** 책임인데 SOUL 규칙을 2회 무시(scratch 기본 유지). decomposer(kanban_decompose.py)는 workspace를 아예 안 다룸. set-default-workdir는 scratch에 무효. shell hook의 인자 rewrite는 셸 명령 정책용이라 kanban_create 주입엔 부적합.
>  - **결론: 이 hermes 버전(0.16)에서 무인 코딩 워커의 산출물 위치를 자동 강제하는 깔끔한 시스템 수단이 없음. LLM(오케스트레이터)이 태스크 생성 시 dir workspace를 지정해야 하나 불안정.**
> 💡 **실용 경로**: ① 작업 지시 시 "workspace_kind=dir, /repos/dev/<프로젝트>에 만들어"를 **명시적으로** 지시(일반 SOUL 규칙보다 직접 지시를 LLM이 잘 따름) ② 또는 프로젝트를 미리 /repos/dev에 독립 레포로 두고 작업(사용자 git 워크플로와 정합) ③ 근본 자동화는 hermes 버전 기능/커스텀 스킬·hook 개발 별도 과제.
>
> ✅ **핵심 돌파 (2026-06-14, 사용자 지적 "SOUL은 프롬프트")**: kanban-worker 스킬 규칙을 재독 — "작업공간 밖 수정 금지, **단 task body가 지시하면 예외**(`unless the task body says to`)". 앞서 이 예외 조항을 간과했음. 즉 **오케스트레이터가 태스크 body에 "코드 작성 경로: /repos/dev/<프로젝트>/"를 명시하면 스킬 예외가 발동**해 coder가 거기 쓴다(workspace_kind 강제 없이도 가능). → 두 SOUL 정렬: dev-orchestrator는 구현 태스크에 (1)workspace_kind=dir (2)body 첫 줄에 코드경로+밖 작성 허가 문구를 **둘 다** 넣게, coder는 body의 경로 지시를 근거로 그 경로에 쓰고 미지정 시 kanban_block. 재시작 완료. → **다음 재요청으로 검증 예정** (스킬-SOUL 충돌 제거 + 명시적 본문 지시로 LLM 준수 가능성 ↑).
>
> ✅✅ **블로커 4 최종 해결·검증 완료 (2026-06-14)**: 재요청 결과 coder가 `/repos/dev/gugudan/gugudan.py` 정상 작성. 구현 태스크 = `workspace: dir @ /repos/dev/gugudan` + body 첫 줄 코드경로 허가 문구 둘 다 적용. qa 반려→coder 수정→qa 재검증 사이클까지 정상(피드백 루프 검증). **성공 원인 3**: ① 스킬과 충돌하는 지시(coder "무조건 절대경로") 대신 스킬 예외("task body가 지시하면 허용")를 통과 ② workspace_kind=dir로 작업공간 자체를 /repos/dev로 이동(scratch 탈출, 이것만으로 충분) ③ SOUL 규칙을 추상 한 줄→구체 행동지시(정확한 본문 문구+이유)로 강화. **교훈: 워커가 SOUL을 무시한 게 아니라 따르던 스킬과 충돌 + 프롬프트가 약했던 것 — LLM 한계가 아니라 프롬프트 엔지니어링 문제였음.**
> ✅ 스모크 결과물 회수: t_daf1c47a의 완성본 gugudan.html(383줄)을 `~/hermes/repos/dev/gugudan/index.html`로 복사 — 호스트 브라우저로 확인 가능.

- [ ] 🧑 dev 테스트: 개발봇에게 초소형 작업 지시 (예: "repos/dev에 hello-world repo 만들고 README 한 줄 작성" — light 등급 예상)
- [ ] 🤖 관찰·기록: 태스크 생성(tenant=dev, 등급 부여 여부) → 디스패처가 coder 기동 → worktree 생성(`task-<ID>-...` 네이밍) → 핸드오프 형식 → 봇 보고. 어긋난 항목을 메모
- [ ] 🧑 dev 테스트 2 (standard 등급 유도): 멀티파일 작업 지시 → coder가 Claude Code를 호출하는지, 핸드오프에 "위임 여부·사용 모델"이 적히는지 확인
- [ ] 🧑 invest 테스트: 투자봇에게 "오늘 나스닥 지수 요약해줘" (모드 1: 직접 응답 — 태스크를 만들지 *않는지* 확인)
- [ ] 🧑 ops 테스트: 운영봇에게 "workspace 변경분 커밋해줘" → ops-worker가 GLOBAL.md 컨벤션으로 분할 커밋하는지, push는 *하지 않는지*(초기 보류 정책) 확인
- [ ] 🤖 보드 상태 점검: `kanban list`로 완료 태스크·핸드오프 확인, 이상 항목 메모
- [ ] 🧑 검수 결과를 바탕으로 SOUL.md 1차 수정 (🤖 보조 — 수정안 제안)

**완료 검증**: 3개 도메인 각 1회전 성공 + 발견된 어긋남이 SOUL.md에 반영됨

---

## Phase 7 — 크론·자동화 등록

목표: 정기 작업이 올바른 소속으로 등록되고 1회 이상 정상 발화.

> ⚠️ 2026-06-13 선행 발견 (hermes_dev 크론 테스트 중):
> ① **타임존 함정**: 컨테이너=UTC + hermes `timezone` 미설정 상태에서 "1분 후" 요청이 00:01 UTC(과거)로 예약됨 → 조치: `timezone: Asia/Seoul`을 루트+프로파일 10개 config에 설정 완료. 크론 등록 후엔 반드시 `cron list`로 Next run이 미래·KST 기준인지 확인할 것
> ② **과거 시각 일회성 잡은 조용히 죽는다**: Next run: None 상태로 남고 실패 알림 없음 — 등록 직후 검증 필요
> ③ `cron list`의 "Gateway is not running" 경고는 root-exec 감지 결함 (실제 티커는 가동 중) — 무시
> ④ **크론 배달 규칙**: 채팅으로 등록한 크론은 `deliver: origin`(등록한 채널로 회신)이 기본. 정기 보고를 `#agents_feed`로 모으려면 등록 시 "결과는 agents_feed 채널로 보내줘"처럼 배달처를 명시할 것. home channel은 출발점 없는 시스템 알림(게이트웨이 기동/종료 등)의 기본 배달처
> ✅ 크론 1회전 검증 완료 (2026-06-13): 등록→Next run KST 미래 시각→정시 발화→origin 채널 배달까지 정상
> ✅ 2026-06-14 사용자 확인: **크론 메커니즘은 hermes_dev 오케스트레이터 크론으로 스모크 검증 완료** (등록·발화·배달). 실제 운영 크론(투자봇 09:00 브리핑 / 운영봇 06:00 커밋)은 invest/ops 워커 실작업 스모크 후 등록 — 미정 항목으로 잔존

- [ ] 🧑 운영봇에게: 매일 06:00 변경분 분할 커밋 크론 등록 (예약 칸반 태스크 → ops-worker 방식, **push 없이 커밋까지**)
- [ ] 🧑 투자봇에게: 매일 09:00 포트폴리오/나스닥 브리핑 크론 등록
- [ ] 🔐 worktree 정리 크론 등록 (완료 태스크의 worktree 삭제 — 주 1회)
- [ ] 🤖 (해당 시) LLM 불필요한 기계적 반복은 컨테이너 일반 cron으로 분리 작성
- [ ] 🤖 검증: 각 크론을 수동 트리거(또는 다음 발화 시각 대기)해 `#agents-feed`에 보고 도착 확인
- [ ] 🤖 검증: ops 보고에 4요소(커밋 목록/도메인 요약/제외한 것/이상 신호) 포함 확인
- [ ] 🤖 커밋: `[infra] 크론 구성 메모` (등록한 크론 목록을 README 또는 ops AGENTS.md에 기록)

**완료 검증**: 크론 3종이 각 1회 이상 정상 보고

---

## Phase 8 — 보안 점검 + 백업 확정

목표: 가이드 §10 체크리스트 전체 통과 + 백업 경로 가동.

- [ ] 🤖 가이드 §10 체크리스트를 항목별로 점검하고 결과표를 이 파일 아래에 기록 (통과/실패/해당없음)
  > 📋 2026-06-13 **사전 점검 (드라이런 — Phase 8 시점에 전체 재검증 예정)**:
  > ✓ Dockerfile/compose 시크릿 주입 없음 ✓ repos 중첩 .git 없음 ✓ .env 전부 600 ✓ .hermes ignore 작동 ✓ 대시보드 127.0.0.1 바인딩
  > ⚠️ **발견**: 호스트 Claude Code `.claude/settings.local.json`에 `Bash(docker *)` auto-allow 존재 (가이드 §8 "docker compose exec auto-allow 금지" 위배) + `.env`/`auth.json` 읽기 deny 규칙 없음 → 조치 필요: deny는 즉시 추가 권장, docker allow 축소는 구축 완료 시점(Phase 8)에 (구축 중엔 조회 명령 빈도가 높아 편의 유지)
  > ✅ 2026-06-13 deny 6건 추가 완료 (사용자 승인): `Read/Edit(**/.env, **/.env.*, .hermes/**/auth.json)`. `Bash(docker *)` allow 축소는 Phase 8에 잔여 (사용자 결정: 구축 편의 우선)
- [ ] 🤖 특별 확인: Dockerfile·compose에 시크릿 부재, repos 안 개별 .git 부재, allowlist 설정값
- [ ] 🧑 GitHub(등)에 **private** 원격 생성 → 🔐 `git remote add` + 첫 push
  > 📋 2026-06-14: 사용자가 `github.com/cha2hyun/hermes` private 레포 생성. **SSH deploy key 방식** 채택(gh 불필요, monorepo push는 외부 에이전트=호스트 담당):
  >  - deploy key 생성: `~/.ssh/hermes_deploy_ed25519` (개인키 600, 미출력) / 공개키 = `ssh-ed25519 AAAAC3...UbEI`
  >  - `~/.ssh/config`에 `github-hermes` 별칭(IdentityFile=deploy key), git remote origin=`git@github-hermes:cha2hyun/hermes.git`
  >  - git author: `cha2hyun` (이전 커밋은 <redacted> author로 남음 — 변경 안 함)
  >  - ✅ 2026-06-14 공개키 등록 완료 → SSH 연결 테스트 통과(`Hi cha2hyun/hermes! ... authenticated`) → 보안 점검 통과 → **첫 push 완료**(`git push -u origin main`)
- [x] 🤖 push 후 원격 저장소 파일 목록에 `.hermes` 부재 확인 (이중 검증)
  > ✅ 2026-06-14 `git ls-tree origin/main` 최상위 = docker/workspace/repos/문서들. `.env`/`.hermes`/`auth.json` 원격에 없음 확인
  > 📋 커밋 규칙 확정(사용자 결정): monorepo 커밋은 **영어 + prefix**(infra/chore/dev/hermes/docs) — 루트 AGENTS.md에 명문화, 기존 로컬 커밋 3개도 소급 적용(reword, author=cha2hyun 통일)
- [ ] 🤖 push 후 원격 저장소 파일 목록에 `.hermes` 부재 확인 (이중 검증)
- [ ] 🧑 Time Machine 제외 등록: `~/hermes/repos`, `~/hermes/workspace/*/worktrees` (+ node_modules)
- [ ] 🧑 호스트 Claude Code 설정 확인: `.env`/`auth.json` ignore, `docker compose exec` auto-allow 아님

**완료 검증**: §10 결과표에 실패 0건 + 원격 push 완료 + 원격에 .hermes 없음

---

## Phase 9 — 1주차 운영 검수 (반복 루프)

목표: 시스템을 "돌아가는 상태"에서 "믿을 수 있는 상태"로. 매일 반복.

- [ ] 🧑 매일: 핸드오프 전수 읽기 → 어기는 규칙은 SOUL.md에서 구체화, 안 쓰는 규칙은 삭제 (🤖 수정안 보조)
- [ ] 🧑 coder 검수: 등급 판정이 적절한가 (light 남발/heavy 남발) → 오케스트레이터 SOUL.md 등급 정의 조정
- [ ] 🧑 메모리 가지치기: `profiles/*/memories` 열어 잘못 박힌 기억 제거 (주 1~2회)
- [ ] 🤖 비용 점검: 대시보드 토큰 분석 + 제공사 콘솔 사용량 확인 안내 → 등급/모델 매핑 조정 제안
- [ ] 🧑 **push 개방 게이트** (2주 차, 아래 조건 충족 시): ops 커밋 메시지·분할 품질 합격 → ops-worker SOUL.md에서 push 허용으로 변경
- [ ] 🧑 알림 피로 점검: 묶을 보고는 브리핑으로 통합, 예외만 멘션

**완료 검증** (= 구축 종료 선언 조건):
- 연속 3일, SOUL.md 수정 없이 모든 핸드오프가 계약을 준수
- ops push 개방 완료
- 이후는 가이드 §13 "그 이후" 항목(역할 분리, 도메인 추가, root, Holographic 등)을 필요 시점에 개별 진행

---

## Blueprint 릴리스 (2026-06-14, v0.1-blueprint)

목표: 구축 결과를 재사용 가능한 템플릿으로. **`.hermes` 전부 ignore 불필요** — 두뇌 구조는 추적, 시크릿·런타임만 제외.

- [x] `.gitignore` 화이트리스트: `.hermes/profiles/*/{SOUL.md,config.yaml,profile.yaml,.env.template}`만 추적, `.env`/`auth.json`/런타임(db/sessions/memories/logs/cache) 제외
- [x] 환경종속 값(Discord 채널ID)을 config `${VAR}` 참조로 분리 — 값은 `.env`. 운영 게이트웨이로 확장 작동 확인(`free_response_channels: ${DISCORD_*_CHANNEL}`)
- [x] `.env.template` ×10 (프로파일별 키 이름), 루트 `.env.example`(공통 키)
- [x] `install.sh`: 루트 `.env`의 `ANTHROPIC_API_KEY`를 각 프로파일 `.env`로 전파(chmod 600) + 런타임 디렉터리 생성 + Discord 셋업 안내. 멱등
- [x] README에 blueprint 설치법
- [x] 커밋 3개(chore/infra/docs) + `v0.1-blueprint` 태그 push (cha2hyun/hermes)
- [x] **클린 재현 검증**: 별도 디렉터리 clone → 더미 키 .env → `./install.sh` → 10 프로파일 `.env` 생성·주입·600·템플릿 보존·멱등·시크릿 미포함 전부 통과
- [ ] (선택) dev-orchestrator config.yaml 팽창본(514줄)을 최소 오버레이로 정리 — `chore:`, 기능 영향 없음
- [ ] (선택) GitHub Release 노트 작성 (웹, gh 미설치)

> 검증된 사실: config.py가 `${VAR}` 확장 지원(저장 시 `_preserve_env_ref_templates`로 참조 보존), hermes distribution도 `.env`/`auth.json`을 USER_OWNED_EXCLUDE로 제외 + `.env.template` 개념 보유 → 우리 방식이 hermes-native 패턴과 일치

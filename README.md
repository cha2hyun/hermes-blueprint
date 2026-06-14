# hermes — Multi-Agent Hub (blueprint)

A personal multi-agent system running three domains (**dev / invest / ops**) in a single Docker container.
You give instructions over Discord; an orchestrator decomposes the work and assigns it to workers, who collaborate through a Kanban board, with cron for unattended automation.

> This repository is a **reusable blueprint**. `git clone` → `./install.sh` → Discord setup reproduces the same system.
> Full design: [`hermes-setup-guide.md`](hermes-setup-guide.md). Step-by-step build log: [`hermes-setup-todo.md`](hermes-setup-todo.md).

---

## What it is

- **Three domains** = workspace folder = tenant = orchestrator, 1:1:1:1
  - `dev` — software planning, design, implementation, QA
  - `invest` — market/company research, risk review
  - `ops` — domain-neutral utilities (git commits, cleanup)
- **Ten profiles** = 3 orchestrators + 7 workers
  - Orchestrators (`*-orchestrator`): open the gateway, route/decompose/report only — never do the work directly
  - Workers: `planner` `designer` `coder` `qa` `analyst` `risk-checker` `ops-worker`
- **Separated execution engine**: `coder` is the Kanban interface; heavy coding is delegated to the container's built-in Claude Code (`claude -p`)
- **Model tiering**: orchestrators = higher tier (opus), workers = mid tier (sonnet)

## Architecture

```
Human ──@mention──▶ Discord ──▶ Orchestrator (resident gateway: route/decompose)
                                    │  creates task (tenant=domain, workspace=dir:/repos/<domain>/<project>)
                                    ▼
                            Kanban board (single .hermes/kanban.db, domains split by tenant)
                                    │  ready task
                                    ▼
                Dispatcher (embedded in gateway) ──▶ Worker (spawned one-shot)
                                                        │  handoff (written to board) → next worker (qa, ...)
                                                        ▼
                            Orchestrator summarizes ──▶ Discord (#agents_feed / per-bot channel)
```

- Workers cannot see each other's memory/sessions — sharing happens **only through the board (handoffs)**. Isolation is the collaboration discipline.
- The dispatcher spawns workers only when needed (zero idle cost). If a worker dies, the board survives and resumes on restart.

## Layout (three-way split by lifecycle)

```
~/hermes/
├── .hermes/      [state]   profile brains (SOUL/config) + Kanban board. Secrets & runtime are git-excluded
├── docker/       [recipe]  Dockerfile + compose.yml — image is disposable, version-pinned
├── workspace/    [work]    GLOBAL.md + per-domain AGENTS.md (rules) + specs/design/qa-reports (artifacts)
└── repos/        [code]    per-domain projects (/repos/<domain>/<project>)
```

Inside `.hermes`, what is **tracked** (brains) vs **excluded** is separated:

| kind | items | git |
|---|---|---|
| brain structure | `profiles/*/SOUL.md`·`config.yaml`·`profile.yaml`·`.env.template` | ✅ tracked (blueprint) |
| secrets | `profiles/*/.env`·`auth.json` | ❌ excluded (injected by install) |
| runtime | `*.db`·`sessions/`·`memories/`·`logs/`·`*_cache/`·`gateway.*` | ❌ excluded (auto-regenerated) |

Environment-specific values (Discord channel IDs) live as `${VAR}` references in config, with actual values in `.env` — only the reference remains in the blueprint.

## Install (reproduce the blueprint)

**Prerequisites**: Docker Desktop, an Anthropic Console API key, a Discord server + 3 bots.

```bash
# 1) clone
git clone https://github.com/cha2hyun/hermes-blueprint.git hermes && cd hermes

# 2) common key
cp .env.example .env        # put ANTHROPIC_API_KEY into .env

# 3) install — generate each profile's .env + propagate the key (chmod 600) + create runtime dirs
./install.sh

# 4) Discord setup (create 3 bots → invite to server → per-bot channels + #agents_feed)
#    put bot token / channel ID / your user ID into each orchestrator .env (see install.sh output)
#    .hermes/profiles/<dev|invest|ops>-orchestrator/.env

# 5) start the container
cd docker && docker compose up -d --build
docker compose exec hermes hermes -p dev-orchestrator    gateway restart
docker compose exec hermes hermes -p invest-orchestrator gateway restart
docker compose exec hermes hermes -p ops-orchestrator    gateway restart
```

> The first build pulls the official image (several GB) and takes a while. See the guide/todo for step-by-step details and troubleshooting.

## Operations

- **hermes CLI runs inside the container**: `docker compose -f docker/compose.yml exec hermes hermes <cmd>`
- **Gateway**: `hermes -p <orchestrator> gateway {start,stop,restart,status}` / `hermes gateway list`
- **Dashboard** (on demand): `docker compose exec hermes hermes dashboard --host 0.0.0.0 --no-open --insecure` → http://127.0.0.1:9119
- **Kanban**: `hermes -p <p> kanban list|show <id>|archive <id>`
- **Usage**: instruct in `#hermes_<domain>` channels (no mention needed); `#agents_feed` collects cron reports/system alerts (mute recommended)

## Security

- Secrets (`.env`/`auth.json`) and operational data are **never committed** (whitelist gitignore) — a clone contains brains only
- Dashboard binds to `127.0.0.1` only; run it on demand
- The container is a sandbox with only 3 mounts (`.hermes`/`workspace`/`repos`) exposed to the host
- Host agent (monorepo git) and Hermes workers (sub-repo git) have separated privileges — see root `AGENTS.md`

## Docs

| file | content |
|---|---|
| [`hermes-setup-guide.md`](hermes-setup-guide.md) | full design principles, architecture, operations roadmap |
| [`hermes-setup-todo.md`](hermes-setup-todo.md) | phase-by-phase build checklist + actual build log & troubleshooting |
| [`AGENTS.md`](AGENTS.md) | host coding-agent operating guide + monorepo commit convention |

## License

MIT — see [LICENSE](LICENSE).

---

# hermes — 멀티 에이전트 허브 (blueprint)

도메인 3개(**dev / invest / ops**)를 하나의 Docker 컨테이너에서 운영하는 개인 멀티 에이전트 시스템.
Discord로 지시하면 오케스트레이터가 작업을 분해해 워커에게 배정하고, 칸반 보드로 협업하며, 크론으로 무인 자동화한다.

> 이 저장소는 **재사용 가능한 blueprint**다. `git clone` → `./install.sh` → Discord 셋업이면 같은 시스템을 재현한다.
> 상세 설계는 [`hermes-setup-guide.md`](hermes-setup-guide.md), 구축 단계별 기록은 [`hermes-setup-todo.md`](hermes-setup-todo.md).

## 무엇인가

- **도메인 3개** = workspace 폴더 = tenant = 오케스트레이터, 1:1:1:1 대응
  - `dev` — 소프트웨어 기획·설계·구현·검증
  - `invest` — 시장·기업 리서치, 리스크 검토
  - `ops` — 도메인 중립 유틸(git 커밋·정리 등)
- **프로파일 10개** = 오케스트레이터 3 + 워커 7
  - 오케스트레이터(`*-orchestrator`): 게이트웨이를 열고 라우팅·분해·보고만. 직접 일하지 않음
  - 워커: `planner` `designer` `coder` `qa` `analyst` `risk-checker` `ops-worker`
- **실행 엔진 분리**: `coder`는 칸반 접점, 무거운 코딩은 컨테이너 내장 Claude Code(`claude -p`)에 위임
- **모델 차등**: 오케스트레이터=상위(opus), 워커=중위(sonnet)

## 아키텍처

```
사람 ──@멘션──▶ Discord ──▶ 오케스트레이터 (게이트웨이 상주, 라우팅·분해)
                                  │  태스크 생성 (tenant=도메인, workspace=dir:/repos/<도메인>/<프로젝트>)
                                  ▼
                          칸반 보드 (단일 .hermes/kanban.db, tenant로 도메인 구분)
                                  │  ready 태스크
                                  ▼
              디스패처 (게이트웨이 내장) ──▶ 워커 (일회성 프로세스로 기동)
                                                │  핸드오프(보드에 기록) → 다음 워커(qa 등)
                                                ▼
                              오케스트레이터가 결과 요약 ──▶ Discord (#agents_feed / 봇 전용 채널)
```

- 워커끼리는 서로의 메모리·세션을 못 봄 — 공유는 **보드(핸드오프)**로만. 격리가 곧 협업 규율
- 디스패처가 워커를 필요할 때만 띄움(평시 리소스 0). 워커가 죽어도 보드는 살아있고 재시작 시 이어짐

## 구조 (수명 주기별 3분할)

```
~/hermes/
├── .hermes/      [상태]   프로파일 두뇌(SOUL/config) + 칸반 보드. 시크릿·런타임은 git 제외
├── docker/       [레시피] Dockerfile + compose.yml — 이미지는 소모품, 버전 핀 고정
├── workspace/    [작업장] GLOBAL.md + 도메인별 AGENTS.md(규칙) + specs/design/qa-reports(산출물)
└── repos/        [코드]   도메인별 프로젝트 (/repos/<도메인>/<프로젝트>)
```

`.hermes` 안에서 **추적되는 것**(두뇌)과 **제외되는 것**을 분리한다:

| 성격 | 항목 | git |
|---|---|---|
| 두뇌 구조 | `profiles/*/SOUL.md`·`config.yaml`·`profile.yaml`·`.env.template` | ✅ 추적 (blueprint) |
| 시크릿 | `profiles/*/.env`·`auth.json` | ❌ 제외 (install이 주입) |
| 런타임 | `*.db`·`sessions/`·`memories/`·`logs/`·`*_cache/`·`gateway.*` | ❌ 제외 (자동 재생성) |

환경종속 값(Discord 채널ID)은 config의 `${VAR}` 참조로 두고 실제 값은 `.env`에 둔다 — blueprint엔 참조만 남는다.

## 설치 (blueprint 재현)

**사전 요건**: Docker Desktop, Anthropic Console API 키, Discord 서버 + 봇 3개.

```bash
# 1) 클론
git clone https://github.com/cha2hyun/hermes-blueprint.git hermes && cd hermes

# 2) 공통 키 입력
cp .env.example .env        # .env 에 ANTHROPIC_API_KEY 입력

# 3) 설치 — 각 프로파일 .env 생성 + 공통 키 전파(chmod 600) + 런타임 디렉터리
./install.sh

# 4) Discord 셋업 (봇 3개 생성 → 서버 초대 → 전용 채널 + #agents_feed)
#    각 오케스트레이터 .env에 봇 토큰·채널ID·본인 사용자ID 입력 (install.sh 안내 참조)
#    .hermes/profiles/<dev|invest|ops>-orchestrator/.env

# 5) 컨테이너 기동
cd docker && docker compose up -d --build
docker compose exec hermes hermes -p dev-orchestrator    gateway restart
docker compose exec hermes hermes -p invest-orchestrator gateway restart
docker compose exec hermes hermes -p ops-orchestrator    gateway restart
```

> 첫 빌드는 공식 이미지(수 GB) 다운로드로 시간이 걸린다. 단계별 상세·트러블슈팅은 guide/todo 참조.

## 운영

- **hermes CLI는 컨테이너 경유**: `docker compose -f docker/compose.yml exec hermes hermes <명령>`
- **게이트웨이**: `hermes -p <orchestrator> gateway {start,stop,restart,status}` / `hermes gateway list`
- **웹 대시보드**(필요할 때만): `docker compose exec hermes hermes dashboard --host 0.0.0.0 --no-open --insecure` → http://127.0.0.1:9119
- **칸반**: `hermes -p <p> kanban list|show <id>|archive <id>`
- **사용 패턴**: `#hermes_<도메인>` 채널에서 멘션 없이 지시 / `#agents_feed`는 크론 보고·시스템 알림(음소거 권장)

## 보안

- 시크릿(`.env`/`auth.json`)·운영 데이터는 **git에 절대 올라가지 않음**(화이트리스트 gitignore) — clone본엔 두뇌 구조만
- 웹 대시보드는 `127.0.0.1`에만 바인딩(공개 금지), 사용할 때만 기동
- 컨테이너는 마운트 3개(`.hermes`/`workspace`/`repos`)만 호스트로 열린 샌드박스
- 호스트 에이전트(monorepo git)와 Hermes 워커(서브레포 git)는 권한 분리 — 루트 `AGENTS.md` 참조

## 문서

| 파일 | 내용 |
|---|---|
| [`hermes-setup-guide.md`](hermes-setup-guide.md) | 전체 설계 원칙·아키텍처·운영 로드맵 |
| [`hermes-setup-todo.md`](hermes-setup-todo.md) | Phase별 구축 체크리스트 + 실제 구축 기록·트러블슈팅 |
| [`AGENTS.md`](AGENTS.md) | 호스트 코딩 에이전트용 운영 지침 + monorepo 커밋 규칙 |

## 라이선스

MIT — [LICENSE](LICENSE) 참조.

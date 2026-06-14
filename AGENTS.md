# ~/hermes 운영 지침 (호스트 코딩 에이전트용)

## 이 프로젝트
Hermes 멀티 에이전트 허브. 전체 설계는 hermes-setup-guide.md 참조.
구조: .hermes(상태) / workspace(작업장) / repos(코드) / docker(레시피)

## 명령 실행 규칙
- 모든 hermes CLI는 컨테이너 경유:
  docker compose -f docker/compose.yml exec hermes hermes <명령>
- 조회·진단(list, doctor, logs)은 자유 실행
- 상태 변경(gateway 시작/중지, restart, profile 생성/삭제, config set)은 제안 후 승인 대기
- config/SOUL.md 편집 후에는 hermes doctor로 검증

## 커밋 규칙 (monorepo ~/hermes — 호스트 에이전트가 관리)
- **영어로만** 작성
- **prefix 필수** (성격에 맞게 택1):
  - `infra:` 인프라 (Docker·게이트웨이·폴더 구조·deploy key 등)
  - `chore:` 정리·잡일 (gitignore, 파일 이동, 의존성 등)
  - `dev:` dev 도메인 코드 (repos/dev 등)
  - `hermes:` hermes 운영·설정 관련
  - `docs:` 문서 (가이드·todo·README 등)
- 형식: `<prefix>: <concise English summary>` + 필요 시 본문 불릿
- ※ Hermes 워커(ops-worker)가 클론된 서브레포에 하는 커밋은 별개 — `workspace/GLOBAL.md`의 `[도메인/프로젝트]` 컨벤션을 따른다 (위 prefix 규칙은 monorepo 전용)

## 금지
- .env, auth.json 읽기·수정·출력 금지
- .hermes/profiles/*/memories, sessions, *.db 수정 금지 (에이전트 자율 영역)
- workspace/*/AGENTS.md는 Hermes 워커용 규칙 — 수정 시 반드시 사전 확인

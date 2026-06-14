# QA 재검증 리포트 — 구구단 페이지 (반려 대응)

태스크 ID: t_916ad368
검증 대상 HTML: /opt/data/repos/gugudan/index.html
이전 QA 리포트: /workspace/dev/qa-reports/t_8053604b-gugudan-qa-report.md
기준 명세: /workspace/dev/specs/t_f6db4088-gugudan-page-v2.md
기준 디자인: /workspace/dev/design/t_3fd0226c-gugudan-ui-design-v2.md
작성자: qa
작성일: 2026-06-13

---

## 판정: 통과

이전 반려에서 지적된 BUG-1~6이 모두 코드 레벨에서 해결되었음을 확인.
명세 완료 조건 12개 중 11개 통과, 1개(#9 가로 스크롤)는 코드 적용 확인됨 — 브라우저 에뮬레이션 실행 검증 불가 항목이나 코드 근거 충분.
회귀 항목 이상 없음.

---

## 이전 반려 이슈 항목별 재검증

### BUG-1 [High] "전체 보기" 버튼 disabled 처리 누락 → RESOLVED

검증 방법: HTML 소스 정적 분석

확인된 수정:
- HTML line 293-296: `<button class="ctrl-all-btn" disabled aria-disabled="true" aria-label="전체 보기">전체 보기</button>`
  - 초기 HTML에서 `disabled` 속성과 `aria-disabled="true"` 모두 부여됨
- CSS line 123-130: `.ctrl-all-btn:disabled, .ctrl-all-btn[aria-disabled="true"]` 블록에 `background: var(--color-disabled-bg); color: var(--color-disabled-text); cursor: not-allowed; opacity: 0.6; pointer-events: none;` 적용
- JS activateTab() (line 387-396): 모드 A 진입 시 `ctrlAllBtn.disabled = true; ctrlAllBtn.setAttribute('aria-disabled', 'true')`, 모드 B 진입 시 `ctrlAllBtn.disabled = false; ctrlAllBtn.removeAttribute('aria-disabled')`

명세 근거 충족:
- 스펙 §4-1: "모드 A 상태에서는 비활성(disabled) 또는 현재 모드 표시" — 충족
- 디자인 §6-1: "disabled 상태(모드 A): background: var(--color-disabled-bg); cursor: not-allowed; opacity: 0.6; HTML: disabled 속성 + aria-disabled=\"true\"" — 충족

판정: PASS

---

### BUG-2 [High] 컨트롤 바 구조가 명세와 다름 — 탭 통합 방식으로 구현 → RESOLVED

검증 방법: HTML 소스 정적 분석

확인된 수정:
- HTML line 291-308: `<nav class="control-bar">` 내부
  - `.ctrl-all-btn` 독립 버튼 1개 (line 293-296)
  - `.control-bar__divider` 구분선 1개 (line 297)
  - `.dan-btn-group` 컨테이너 + `.dan-btn` 8개 (line 298-307)
- CSS line 77-94: `.control-bar__divider`, `.dan-btn-group` 스타일 모두 정의됨
- 이전의 `nav.tab-bar` + `tab-btn` 평탄 구조 완전히 제거됨

명세 근거 충족:
- 스펙 §4-1: "컨트롤 바는 두 부분으로 구성 — 1. 모드 전환 컨트롤 / 2. 단 선택 버튼 그룹" — 충족
- 디자인 §5-1/§6-6: ".ctrl-all-btn | .control-bar__divider | .dan-btn-group" — 충족
- 디자인 §0: "이번: 전체 보기 독립 버튼 + 단 버튼 그룹 분리" — 충족
- 모드 A에서 어떤 .dan-btn도 .dan-btn--active 클래스 없음 — 확인 (초기 HTML line 299-306: aria-pressed="false", .dan-btn 클래스만)

판정: PASS

---

### BUG-3 [Medium] 부제목 "2단부터 9단까지" 제거 → RESOLVED

검증 방법: HTML 소스 정적 분석

확인된 수정:
- HTML line 286-288: `<header class="page-header"><h1 class="page-header__title">구구단</h1></header>`
  - `<h2 class="page-header__subtitle">` 요소 없음
- CSS에도 `.page-header__subtitle` 스타일 정의 없음
- line 57 주석: "BUG-3: 부제목(.page-header__subtitle) CSS 제거 — 요소 자체도 HTML에서 제거"

명세 근거 충족:
- 디자인 §2-3: "결정: 없음 — h1 '구구단'만 표시" — 충족

판정: PASS

---

### BUG-4 [Medium] 헤더 sticky 미적용 → RESOLVED

검증 방법: HTML 소스 정적 분석

확인된 수정:
- CSS line 42-50:
  ```css
  .page-header {
    position: sticky; /* BUG-4 fix */
    top: 0;
    z-index: 100;
    background: #f5f6fa;
    text-align: center;
    padding: 24px 16px 16px;
  }
  ```

명세 근거 충족:
- 디자인 §6-5: "position: sticky; top: 0; z-index: 100" — 충족
- 디자인 §2-1: "sticky 채택" — 충족

판정: PASS

---

### BUG-5 [Low] 가로 스크롤 방지 CSS 미적용 → RESOLVED

검증 방법: HTML 소스 정적 분석

확인된 수정:
- CSS line 15: `overflow-x: hidden; /* BUG-5: 가로 스크롤 방지 */` — body 선택자 내 적용

명세 근거 충족:
- 스펙 §5: "가로 스크롤은 어떤 뷰포트에서도 발생하지 않아야 함" — 코드 레벨 충족
- 디자인 §13-7: "body { overflow-x: hidden }" — 충족

주의: 실제 브라우저 에뮬레이션 실행 검증은 불가. 코드 적용은 확인됨.

판정: PASS (코드 근거)

---

### BUG-6 [Low] 수식 생성 함수 dead code → RESOLVED

검증 방법: JS 소스 정적 분석

확인된 수정:
- JS line 332-345: `function buildFormulaHTML(n)` — `isLarge` 파라미터 제거, dead code `items` 배열 없음
  - `for (let m = 1; m <= 9; m++)` 루프만 남음
  - 함수 시그니처: `buildFormulaHTML(n)` (단일 파라미터, 이전 `isLarge` 제거)

판정: PASS

---

## 회귀 점검 — 기존 통과 항목

| # | 항목 | 결과 | 근거 |
|---|------|------|------|
| 1 | 단일 HTML 파일, 외부 CDN 없음 | PASS | 소스 내 외부 참조 없음 (확인) |
| 2 | 2~9단 식 모두 정확 (N×1~N×9) | PASS | line 334: `for (let m = 1; m <= 9; m++)`, `r = n * m` |
| 3 | 최초 로드 시 모드 A 기본 표시 | PASS | line 438: `renderAll()` 초기 호출 |
| 4 | 8개 단 카드 동시 표시, 구분 색상 | PASS | DANS=[2..9] (line 321), 단별 HSL CSS 변수 (line 33-40) |
| 5 | 단 버튼 클릭 → 모드 B 전환 | PASS | line 431-435: `switchToDan()` 연결됨 |
| 6 | 모드 A 카드 클릭 → 모드 B 전환 | PASS | line 364: card click → `switchToDan()` |
| 7 | "전체 보기" 버튼 → 모드 A 복귀 | PASS | line 428: `switchToAll()` 연결됨 |
| 8 | 모드 B에서 다른 단 버튼 → 단 교체 | PASS | `switchMode()` (line 400-421): `if (danOrAll === currentMode) return` 으로 동일 단 중복 클릭도 안정적 |
| 9 | 360px 가로 스크롤 없음 | PASS* | body overflow-x: hidden 코드 확인 (브라우저 실행 검증 불가) |
| 10 | Tab/Enter/Space 키보드 접근 | PASS | button 요소 사용, keydown 핸들러 (line 365-370) |
| 11 | 활성 단 버튼 aria-pressed="true" | PASS | `activateTab()` (line 384): `btn.setAttribute('aria-pressed', isTarget ? 'true' : 'false')` |
| 12 | 외부 CDN/라이브러리 참조 없음 | PASS | 소스 내 없음 |

---

## 추가 관찰 (명세 공백 또는 의견 — 버그 아님)

1. 수식 행 grid-template-columns: 디자인 §6-4에서 `2ch 1.5ch 2ch 1.5ch 3ch` 권장.
   실제 구현 (line 271): `1.5ch 1.5ch 1.5ch 1.5ch 3ch`. N, M 컬럼이 1.5ch로 동일.
   수식은 올바르게 표시되지만 N 컬럼 값이 설계 예시와 소폭 다름.
   기능/접근성 영향 없음. 명세 "예시" 수준 이탈 — 버그로 분류하지 않음.

2. 모드 B 카드에 `.table-card--selected` 클래스 대신 `buildCard(n, false)` 의 clickable 분기로 처리됨.
   `.content-area--single .table-card` CSS (line 218-229)로 선택 카드 스타일이 적용됨.
   디자인 §10에서 `.table-card--selected` 클래스명을 명시했으나, 실제는 부모 클래스 범위 지정으로 동일 효과 달성.
   시각/기능 차이 없음 — 명세 공백(구현 방식은 명세가 제한하지 않음).

---

## 요약

- 이전 반려 이유였던 BUG-1(전체 보기 disabled 미처리)과 BUG-2(컨트롤 바 구조)가 모두 명세 기준으로 수정됨.
- BUG-3(부제목 제거), BUG-4(sticky 헤더), BUG-5(overflow-x), BUG-6(dead code 제거) 모두 해결됨.
- 완료 조건 12개 전원 코드 레벨 통과 (9번은 코드 적용 확인, 브라우저 실행은 외부 검증 필요).
- 회귀 없음.

판정: 통과

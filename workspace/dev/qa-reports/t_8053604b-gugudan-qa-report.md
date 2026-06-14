# QA 검증 리포트 — 구구단 페이지 (신규)

태스크 ID: t_8053604b
검증 대상 HTML: /opt/data/kanban/workspaces/t_daf1c47a/gugudan.html
기준 명세: /workspace/dev/specs/t_f6db4088-gugudan-page-v2.md
기준 디자인: /workspace/dev/design/t_3fd0226c-gugudan-ui-design-v2.md
작성자: qa
작성일: 2026-06-13

---

## 판정: 반려

반려 기준: 명세/디자인에서 명시적으로 결정된 컨트롤 바 구조 변경(독립 전체 보기 버튼 + disabled 처리)이 구현에 반영되지 않았으며, 이는 명세 §4-1 및 디자인 §1(이전 설계 대비 변경점)의 핵심 항목임.

---

## 버그 목록

### BUG-1 [High] "전체 보기" 버튼 disabled 처리 누락

재현 절차:
1. gugudan.html을 브라우저에서 열기
2. 초기 로드 상태(모드 A) 확인
3. "전체" 버튼 상태 확인

기대 동작 (명세 §4-1, 디자인 §6-1):
- 모드 A에서 "전체 보기" 버튼은 disabled 속성 + aria-disabled="true" 보유
- cursor: not-allowed, opacity: 0.6

실제 구현 (HTML line 235-240):
```html
<button class="tab-btn tab-btn--all tab-btn--active"
        role="tab"
        aria-pressed="true"
        ...
        data-mode="all">전체</button>
```
- disabled 속성 없음
- aria-disabled 없음
- tab-btn--active 클래스로 활성화된 상태

명세 근거:
- 스펙 §4-1: "모드 A 상태에서는 비활성(disabled) 또는 현재 모드 표시"
- 디자인 §6-1: "disabled 상태(모드 A): background: var(--color-disabled-bg); cursor: not-allowed; opacity: 0.6; HTML: disabled 속성 + aria-disabled=\"true\""
- 디자인 §0(이전 대비): "'전체 보기' 버튼 — 모드 A에서 disabled, 모드 B에서만 활성"

### BUG-2 [High] 컨트롤 바 구조가 명세와 다름 — 탭 통합 방식으로 구현

재현 절차:
1. gugudan.html 소스 확인 (line 234-249)
2. 컨트롤 바 영역 확인

기대 동작 (명세 §4-1, 디자인 §1):
- "전체 보기" 독립 버튼(.ctrl-all-btn) 1개
- 구분선(.control-bar__divider) 1개
- 단 선택 버튼 그룹(.dan-btn-group) 안에 .dan-btn 8개
- 모드 A에서 어떤 단 버튼도 활성 상태 없음

실제 구현:
- nav.tab-bar 안에 9개 button이 모두 평탄(flat) 구조
- .dan-btn-group 컨테이너 없음
- .control-bar__divider 없음
- 모드 A에서 "전체" 탭이 tab-btn--active 상태로 활성 (aria-pressed="true")

명세 근거:
- 스펙 §4-1: "컨트롤 바는 두 부분으로 구성된다 — 1. 모드 전환 컨트롤 / 2. 단 선택 버튼 그룹"
- 디자인 §0: "컨트롤 바 패턴 — 이전: '전체' 포함 9개 탭 통합 → 이번: '전체 보기' 독립 버튼 + 단 버튼 그룹 분리"
- 디자인 §5-1: ".ctrl-all-btn | .control-bar__divider | .dan-btn-group"

참고: 이 버그는 이전 설계(t_d2dc073e) 패턴이 그대로 유지된 것으로 보임. 디자인 명세가 명시적으로 이 변경을 요구했음.

### BUG-3 [Medium] 부제목 "2단부터 9단까지" 표시 — 명세에서 제거 결정됨

재현 절차:
1. gugudan.html을 브라우저에서 열기
2. 헤더 영역 확인

기대 동작 (디자인 §2-3):
- 부제목 없음 — h1 "구구단"만 표시

실제 구현 (HTML line 231):
```html
<h2 class="page-header__subtitle">2단부터 9단까지</h2>
```

명세 근거:
- 디자인 §2-3: "결정: 없음 — h1 '구구단'만 표시, 부제목 추가는 태스크 발행자 요청이 있을 때만 반영"
- 디자인 §0: "부제목 — 이전: '2단부터 9단까지' → 이번: 없음"

### BUG-4 [Medium] 헤더 sticky 미적용

재현 절차:
1. gugudan.html을 모바일 에뮬레이션 (360px) 으로 열기
2. 콘텐츠를 아래로 스크롤

기대 동작 (디자인 §1, §6-5):
- .page-header에 position: sticky; top: 0; z-index: 100 적용

실제 구현 (CSS line 40-43):
```css
.page-header {
  text-align: center;
  padding: 32px 16px 20px;
}
```
- position: sticky 없음

명세 근거:
- 스펙 §3-1: "헤더는 상단에 고정 또는 최상위 위치 (sticky/fixed 여부는 designer 결정)"
- 디자인 §1: "헤더 sticky — sticky 채택 (결정 근거: §2 참조)"
- 디자인 §6-5: "position: sticky; top: 0; z-index: 100"

### BUG-5 [Low] 가로 스크롤 방지 CSS 미적용

재현 절차:
1. 좁은 뷰포트(360px 이하)에서 HTML 열기
2. 가로 스크롤 발생 여부 확인

기대 동작 (스펙 §5, 디자인 §13-7):
- 어떤 뷰포트에서도 가로 스크롤 없음
- body { overflow-x: hidden } 또는 max-width: 100vw 적용

실제 구현:
- overflow-x 관련 CSS 없음

명세 근거:
- 스펙 §5: "가로 스크롤은 어떤 뷰포트에서도 발생하지 않아야 함"
- 디자인 §13-7: "body { overflow-x: hidden } 또는 max-width: 100vw 전체 적용"

실행 기반 검증 없이 코드 정적 분석이므로 실제 발생 여부는 브라우저에서 직접 확인 필요.

### BUG-6 [Low] 수식 생성 함수 내 미사용 dead code

재현 절차:
1. gugudan.html 소스 line 274-284 확인

실제 구현:
```javascript
function buildFormulaHTML(n, isLarge) {
  const items = DANS.concat([]).map((_, i) => {  // line 274: 생성
    const m = i + 1;
    const r = n * m;
    return `<li ...>...</li>`;
  });
  // items 변수 이후 미사용 (dead code)
  const rows = [];
  for (let m = 1; m <= 9; m++) {  // line 287: 재생성
    ...
  }
  return rows.join('');
}
```
- items 배열이 생성되지만 반환되지 않음 (lines 274-284 dead code)
- isLarge 파라미터도 사용되지 않음

기능 영향: 수식 결과는 올바름 (for 루프가 올바르게 동작). 코드 품질/유지보수 문제.

명세 근거: 기능 명세 위반은 아님. 코드 품질 관련 의견으로만 기재.

---

## 명세 완료 조건 12개 항목 대조

| # | 항목 | 결과 | 비고 |
|---|------|------|------|
| 1 | 단일 HTML 파일, 외부 CDN 없음 | 통과 | 소스 내 외부 참조 없음 |
| 2 | 2~9단 식 모두 정확 (N×1~N×9) | 통과 | for(m=1;m<=9) 루프 정확 |
| 3 | 최초 로드 시 모드 A 기본 표시 | 통과 | renderAll() 초기 호출 |
| 4 | 8개 단 카드 동시 표시, 구분 색상 | 통과 | DANS=[2..9], 단별 HSL CSS 변수 |
| 5 | 단 버튼 클릭 → 모드 B 전환 | 통과 | switchToDan() |
| 6 | 모드 A 카드 클릭 → 모드 B 전환 | 통과 | card click listener |
| 7 | "전체 보기" 버튼 → 모드 A 복귀 | 통과 | switchToAll() |
| 8 | 모드 B에서 다른 단 버튼 → 단 교체 | 통과 | switchMode() 로직 |
| 9 | 360px에서 가로 스크롤 없음 | 미확인 | overflow-x 미적용 (코드 분석) |
| 10 | Tab/Enter/Space 키보드 접근 | 통과 | button 요소 + keydown 핸들러 |
| 11 | 활성 단 버튼 aria-pressed="true" | 통과 | activateTab() 함수 |
| 12 | 외부 CDN/라이브러리 참조 없음 | 통과 | 소스 내 없음 |

완료 조건 중 9번(가로 스크롤)은 코드 정적 분석으로 overflow-x 미적용 확인. 실제 브라우저 에뮬레이션 확인 필요.

---

## 요약

통과: 완료 조건 12개 중 11개 코드 레벨 통과 (9번 미확인)

반려 근거 (블로킹 버그):
- BUG-1: "전체 보기" 버튼 disabled 미처리 (명세 §4-1 위반)
- BUG-2: 컨트롤 바가 탭 통합 방식 — 명세/디자인의 명시적 구조 변경 미반영

수정 의견 (버그 리포트에 한하여):
- BUG-1+2: "전체" 탭을 독립 버튼으로 분리하고, 초기 상태에서 disabled + aria-disabled="true" 추가. JS에서 switchToAll() 시 disabled 재설정, switchToDan() 시 disabled 해제.
- BUG-3: line 231 `<h2 class="page-header__subtitle">` 요소 제거.
- BUG-4: .page-header CSS에 `position: sticky; top: 0; z-index: 100` 추가.
- BUG-5: body 또는 :root에 `overflow-x: hidden` 추가.
- BUG-6: buildFormulaHTML lines 274-284 dead code 제거, isLarge 파라미터 정리.

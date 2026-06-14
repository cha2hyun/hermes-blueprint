# 구구단 페이지 UI 설계 명세

태스크 ID: t_d2dc073e
참조 스펙: /workspace/dev/specs/t_fe0ecf5e-gugudan-page.md
작성자: designer
작성일: 2026-06-13

---

## 1. 설계 결정 요약

| 항목 | 결정 | 근거 |
|------|------|------|
| 레이아웃 패턴 | Header + Controls + Content 3단 구조 | 스크롤 없이 한 화면에 보여야 하는 요구사항 |
| 모드 전환 컨트롤 | 상단 고정 탭 바 (2~9 숫자 탭 + "전체" 탭) | 탭 한 행으로 8개 단 + 전체 전환을 모두 처리 |
| 카드 그리드 | CSS Grid, auto-fill + minmax | 반응형 자동 열 계산, 미디어쿼리 최소화 |
| 색상 시스템 | 단별 HSL 팔레트 (hue 30° 간격) | 8가지 시각적 구분, 접근성 확보 |
| 단 카드 클릭 확대 | 구현 (선택 사항 → 구현 권장) | 모드 B 탭과 동일 동작, UX 일관성 향상 |
| 페이지 부제목 | "2단부터 9단까지" (h2 수준) | 스펙 미확정이나 간단한 맥락 제공으로 결정 |

---

## 2. 색상 팔레트

### 단별 색상 (HSL 기반)

| 단 | 이름 | Card BG | Card Border | Tab Active BG | Tab Text |
|----|------|---------|-------------|---------------|----------|
| 2단 | Sky Blue | hsl(210, 85%, 94%) | hsl(210, 75%, 55%) | hsl(210, 75%, 55%) | #fff |
| 3단 | Mint Green | hsl(150, 70%, 92%) | hsl(150, 60%, 42%) | hsl(150, 60%, 42%) | #fff |
| 4단 | Coral | hsl(20, 90%, 94%) | hsl(20, 80%, 58%) | hsl(20, 80%, 58%) | #fff |
| 5단 | Violet | hsl(270, 75%, 94%) | hsl(270, 65%, 58%) | hsl(270, 65%, 58%) | #fff |
| 6단 | Amber | hsl(40, 90%, 92%) | hsl(40, 80%, 50%) | hsl(40, 80%, 50%) | #1a1a1a |
| 7단 | Rose | hsl(340, 80%, 94%) | hsl(340, 70%, 58%) | hsl(340, 70%, 58%) | #fff |
| 8단 | Teal | hsl(180, 70%, 92%) | hsl(180, 60%, 40%) | hsl(180, 60%, 40%) | #fff |
| 9단 | Indigo | hsl(230, 75%, 94%) | hsl(230, 65%, 55%) | hsl(230, 65%, 55%) | #fff |

> 6단(Amber)만 텍스트를 어두운 색으로 설정 — 밝은 황색 배경에서 대비율 확보

### 중립 색상

```
--color-bg:         #f5f6fa      /* 페이지 배경 */
--color-surface:    #ffffff      /* 카드/패널 기본 흰 배경 */
--color-text:       #1a1a2e      /* 본문 텍스트 */
--color-text-muted: #6b7280      /* 보조 텍스트 */
--color-tab-bg:     #e8e9f0      /* 비활성 탭 배경 */
--color-tab-text:   #374151      /* 비활성 탭 텍스트 */
--color-border:     #d1d5db      /* 일반 테두리 */
--color-shadow:     rgba(0,0,0,0.10)
```

---

## 3. 타이포그래피

```
폰트 스택: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
등호/수식 폰트: 'Courier New', Courier, 'Lucida Console', monospace

h1 (페이지 제목)  : 2.0rem / 700 / color-text / letter-spacing: -0.02em
h2 (부제목)       : 1.0rem / 400 / color-text-muted
카드 제목(N단)    : 1.25rem / 700 / 단 border 색
수식 행           : 1.0rem  / 400 / color-text / monospace / line-height: 2.0
탭 레이블         : 0.95rem / 600 / 각 단 색상 또는 color-tab-text
```

---

## 4. 레이아웃 — 데스크톱 (≥768px)

```
┌─────────────────────────────────────────────────────────┐
│  HEADER (h1: 구구단 / h2: 2단부터 9단까지)              │
│  text-align: center | padding: 32px 16px 20px           │
├─────────────────────────────────────────────────────────┤
│  TAB BAR (단 선택 컨트롤)                                │
│  [ 전체 ][ 2 ][ 3 ][ 4 ][ 5 ][ 6 ][ 7 ][ 8 ][ 9 ]      │
│  display: flex | gap: 6px | justify-content: center     │
│  padding: 0 16px 24px                                   │
├─────────────────────────────────────────────────────────┤
│  CONTENT AREA                                           │
│  모드 A: CSS Grid 4열 | 모드 B: 단일 카드 중앙 배치      │
│  padding: 0 24px 32px                                   │
└─────────────────────────────────────────────────────────┘
```

### 모드 A — 전체 보기 그리드

```
display: grid
grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))
gap: 16px
max-width: 960px
margin: 0 auto
```

데스크톱(≥768px)에서 200px minmax → 자연스럽게 4열 형성

### 모드 B — 단 선택 보기

```
display: flex
justify-content: center

.selected-card {
  width: 100%
  max-width: 480px
  padding: 32px 40px
  /* 단별 색상 + border 4px */
}

수식 행 font-size: 1.25rem (모드 A보다 크게)
```

---

## 5. 레이아웃 — 모바일/태블릿

### < 480px (모바일)

```
TAB BAR:
  display: grid
  grid-template-columns: repeat(5, 1fr)  /* 전체+2~5 / 6~9 두 행 */
  /* 또는 flex-wrap: wrap + 각 탭 min-width: 40px */

CONTENT GRID:
  grid-template-columns: repeat(2, 1fr)  /* 2열 */
  gap: 12px
  padding: 0 12px 24px
```

### 480px ~ 767px (태블릿)

```
CONTENT GRID:
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr))  /* 2~3열 */
  gap: 14px
```

---

## 6. 컴포넌트 명세

### 6-1. 탭 버튼 (.tab-btn)

```
기본 상태:
  background: var(--color-tab-bg)
  color: var(--color-tab-text)
  border: 2px solid transparent
  border-radius: 8px
  padding: 8px 14px
  font-size: 0.95rem
  font-weight: 600
  cursor: pointer
  transition: background 0.15s, transform 0.1s

hover 상태:
  background: <단별 border 색, 20% opacity>
  /* 예: hsl(210, 75%, 55%, 0.2) */
  transform: translateY(-1px)

active (눌릴 때):
  transform: translateY(0)

선택된 상태 (.tab-btn--active):
  background: <단별 Active BG 색>
  color: <단별 Tab Text 색>
  border-color: <단별 border 색>
  font-weight: 700
  /* 추가: 하단 밑줄 or box-shadow 가능 */
  box-shadow: 0 2px 8px var(--color-shadow)

"전체" 탭 선택 상태:
  background: var(--color-text)
  color: #ffffff
  border-color: transparent

접근성:
  role="tab" 또는 button
  aria-pressed="true" (선택 시)
  tabindex: 0 (포커스 가능)
  :focus-visible { outline: 2px solid <단별 border>; outline-offset: 2px }
```

### 6-2. 단 카드 (.table-card)

```
기본 상태:
  background: <단별 Card BG>
  border: 2px solid <단별 Card Border>
  border-radius: 12px
  padding: 20px
  box-shadow: 0 2px 6px var(--color-shadow)
  transition: box-shadow 0.15s, transform 0.15s, border-width 0.15s
  cursor: pointer  /* 클릭 시 모드 B로 전환 */

hover 상태:
  box-shadow: 0 6px 20px var(--color-shadow)
  transform: translateY(-2px)

active (눌릴 때):
  transform: translateY(0)
  box-shadow: 0 2px 6px var(--color-shadow)

선택된 상태 (모드 B의 단일 카드):
  border-width: 4px
  box-shadow: 0 8px 24px <단별 border 색, 30% opacity>
  /* 예: 0 8px 24px hsl(210, 75%, 55%, 0.3) */

카드 제목 (.card-title):
  font-size: 1.25rem
  font-weight: 700
  color: <단별 border 색>
  margin-bottom: 12px

수식 목록 (.formula-list):
  list-style: none
  padding: 0
  margin: 0

수식 행 (.formula-item):
  font-family: monospace
  font-size: 1.0rem (모드 A) / 1.25rem (모드 B)
  line-height: 2.0
  color: var(--color-text)
  /* 수식 정렬: N, ×, M, =, R 각각 span으로 감싸 text-align 맞춤 가능 */

접근성:
  카드에 role="button" + aria-label="N단 선택"
  tabindex: 0
  :focus-visible { outline: 2px solid <단별 border>; outline-offset: 3px }
```

### 6-3. 헤더 (.page-header)

```
text-align: center
padding: 32px 16px 20px

h1 { font-size: 2.0rem; font-weight: 700; color: var(--color-text); margin: 0 }
h2 { font-size: 1.0rem; font-weight: 400; color: var(--color-text-muted); margin: 4px 0 0 }
```

### 6-4. 탭 바 컨테이너 (.tab-bar)

```
display: flex
flex-wrap: wrap
gap: 6px
justify-content: center
padding: 0 16px 24px
```

### 6-5. 콘텐츠 영역 (.content-area)

```
모드 A (.mode-all):
  display: grid
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))
  gap: 16px
  max-width: 960px
  margin: 0 auto
  padding: 0 24px 32px

모드 B (.mode-single):
  display: flex
  justify-content: center
  padding: 0 24px 32px
```

---

## 7. 인터랙션 & 상태 전이

```
초기 로드
  → 모드 A 활성
  → "전체" 탭 .tab-btn--active
  → 8개 카드 모두 표시

탭 버튼(2~9) 클릭
  → 이전 .tab-btn--active 제거
  → 클릭한 탭에 .tab-btn--active 추가
  → 콘텐츠 영역: .mode-all 제거 + .mode-single 추가
  → 해당 단 카드만 렌더링 (또는 표시)

"전체" 탭 클릭
  → 이전 .tab-btn--active 제거
  → "전체" 탭에 .tab-btn--active 추가
  → 콘텐츠 영역: .mode-single 제거 + .mode-all 추가
  → 8개 카드 모두 표시

모드 A에서 카드 클릭
  → 해당 단 탭 버튼과 동일한 동작 (모드 B로 전환, 해당 단 탭 활성화)

모드 전환 시:
  스크롤 위치 초기화 (window.scrollTo(0, 0) 또는 기본)
  애니메이션 없이 즉시 전환 (setTimeout 미사용)
  깜빡임 방지: display 전환 대신 CSS class 토글로 visibility/opacity 처리 가능
  권장: content-area에 opacity: 0 → 1 (0.1s) 간단 페이드만 허용
```

---

## 8. 빈/오류/로딩 상태

이 페이지는 외부 데이터 없음 (순수 클라이언트 사이드 연산). 별도 로딩/오류 상태 없음.

예외: JS 비활성 환경 → `<noscript>` 태그로 "JavaScript가 필요합니다" 안내 표시 권장 (필수는 아님).

---

## 9. 수식 표시 상세

```html
<!-- 수식 행 마크업 예시 (명세 목적 스니펫) -->
<li class="formula-item">
  <span class="num">2</span>
  <span class="op">&times;</span>
  <span class="num">3</span>
  <span class="eq">=</span>
  <span class="result">6</span>
</li>
```

```css
/* CSS 예시 */
.formula-item {
  display: grid;
  grid-template-columns: 1.5ch 1.5ch 1.5ch 1.5ch 3ch;
  gap: 4px;
  align-items: center;
  font-family: 'Courier New', monospace;
}
.formula-item .num,
.formula-item .op,
.formula-item .eq,
.formula-item .result {
  text-align: right;
}
```

grid-template-columns를 고정 ch 단위로 쓰면 N, ×, M, =, R 각 컬럼이 모든 식에서 정렬됨.

---

## 10. CSS 변수 구조 (coder 구현 참고)

```css
:root {
  /* 중립 */
  --color-bg: #f5f6fa;
  --color-surface: #ffffff;
  --color-text: #1a1a2e;
  --color-text-muted: #6b7280;
  --color-tab-bg: #e8e9f0;
  --color-tab-text: #374151;
  --color-border: #d1d5db;
  --color-shadow: rgba(0, 0, 0, 0.10);

  /* 단별 색상: JS에서 data-dan 속성으로 참조 */
}

/* 단별 CSS Custom Properties */
[data-dan="2"] { --dan-bg: hsl(210,85%,94%); --dan-border: hsl(210,75%,55%); --dan-tab-text: #fff; }
[data-dan="3"] { --dan-bg: hsl(150,70%,92%); --dan-border: hsl(150,60%,42%); --dan-tab-text: #fff; }
[data-dan="4"] { --dan-bg: hsl(20,90%,94%);  --dan-border: hsl(20,80%,58%);  --dan-tab-text: #fff; }
[data-dan="5"] { --dan-bg: hsl(270,75%,94%); --dan-border: hsl(270,65%,58%); --dan-tab-text: #fff; }
[data-dan="6"] { --dan-bg: hsl(40,90%,92%);  --dan-border: hsl(40,80%,50%);  --dan-tab-text: #1a1a1a; }
[data-dan="7"] { --dan-bg: hsl(340,80%,94%); --dan-border: hsl(340,70%,58%); --dan-tab-text: #fff; }
[data-dan="8"] { --dan-bg: hsl(180,70%,92%); --dan-border: hsl(180,60%,40%); --dan-tab-text: #fff; }
[data-dan="9"] { --dan-bg: hsl(230,75%,94%); --dan-border: hsl(230,65%,55%); --dan-tab-text: #fff; }
```

---

## 11. 클래스 네이밍 구조 (BEM 스타일)

```
.page-header
  .page-header__title       ← h1
  .page-header__subtitle    ← h2

.tab-bar
  .tab-btn                  ← 기본 탭 버튼
  .tab-btn--all             ← "전체" 탭
  .tab-btn--active          ← 현재 선택된 탭

.content-area
  .content-area--all        ← 모드 A 그리드 상태
  .content-area--single     ← 모드 B 단일 카드 상태

.table-card                 ← 단 카드 (data-dan="N" 속성 포함)
  .table-card--selected     ← 모드 B에서 표시 중인 카드
  .table-card__title        ← "N단" 제목
  .table-card__list         ← ul.formula-list

.formula-item               ← 개별 수식 행
  .formula-item__num        ← N, M 숫자
  .formula-item__op         ← × 기호
  .formula-item__eq         ← = 기호
  .formula-item__result     ← 결과 R
```

---

## 12. 반응형 미디어쿼리 요약

```css
/* 기본 (모바일 우선) */
.content-area--all {
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  padding: 0 12px 24px;
}
.tab-btn { padding: 6px 10px; font-size: 0.875rem; }

@media (min-width: 480px) {
  .content-area--all {
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 14px;
    padding: 0 16px 28px;
  }
}

@media (min-width: 768px) {
  .content-area--all {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 16px;
    padding: 0 24px 32px;
    max-width: 960px;
    margin: 0 auto;
  }
  .tab-btn { padding: 8px 14px; font-size: 0.95rem; }
}
```

---

## 13. 접근성 체크리스트

| 항목 | 구현 방법 |
|------|----------|
| 키보드 탭 이동 | 탭 버튼 tabindex=0, 카드 tabindex=0 |
| Enter/Space 활성화 | button 요소 사용 (기본 동작) 또는 keydown 핸들러 |
| 색상 외 상태 구분 | 선택 탭: aria-pressed="true" + font-weight: 700 + 밑줄 or 테두리 |
| 포커스 표시 | :focus-visible outline 명시 (reset CSS 삭제 금지) |
| 카드 역할 명시 | role="button" + aria-label="N단 보기" |
| 수식 의미 전달 | aria-label="N 곱하기 M 는 R" (선택 사항, 구현 비용 감안) |

---

## 14. 미해결 이슈 / coder 주의사항

1. **단 카드 클릭 확대** — 필수 아님(스펙 §4 주석)이나 이 설계에서는 구현 권장으로 판단. coder가 구현 범위를 확인 후 제외 가능.
2. **페이지 부제목** — "2단부터 9단까지"로 결정했으나 태스크 발행자가 다른 텍스트를 원할 경우 교체 가능.
3. **모드 전환 애니메이션** — 명세에서 깜빡임 최소화를 요구함. opacity 0→1 0.1s 페이드만 허용 권장. transform 애니메이션은 빠른 탭 전환 시 레이아웃 충돌 우려로 제외.
4. **카드 높이 통일** — 모드 A에서 모든 카드가 동일 높이(9행)이므로 height 고정 불필요. 하지만 grid-auto-rows를 설정하면 더 안정적인 그리드 유지 가능.

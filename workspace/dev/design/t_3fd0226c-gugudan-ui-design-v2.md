# 구구단 페이지 UI 설계 명세 (v2)

태스크 ID: t_3fd0226c
참조 스펙: /workspace/dev/specs/t_f6db4088-gugudan-page-v2.md
작성자: designer
작성일: 2026-06-13

---

## 0. 이전 설계(t_d2dc073e)와의 차이점 요약

| 항목 | 이전(t_d2dc073e) | 이번(t_3fd0226c) |
|------|-----------------|-----------------|
| 컨트롤 바 패턴 | "전체" 포함 9개 탭 통합 | "전체 보기" 독립 버튼 + 단 버튼 그룹 분리 |
| 전체 보기 버튼 | 항상 활성 탭으로 선택 가능 | 모드 A에서 disabled, 모드 B에서만 활성 |
| 단 버튼 상태 | 모드 A에서 "전체" 탭 활성 | 모드 A에서 어떤 단 버튼도 활성 없음 |
| 헤더 sticky | 미정 | sticky 채택 (결정 근거: §2 참조) |
| 카드 scale-up | 권장으로 표기 | 포함 (결정 근거: §2 참조) |
| 부제목 | "2단부터 9단까지" | 없음 (결정 근거: §2 참조) |

색상 팔레트, 타이포그래피, CSS 변수 구조, BEM 네이밍, 접근성 체크리스트는 이전 설계를 그대로 계승한다.

---

## 1. 설계 결정 요약

| 항목 | 결정 | 근거 |
|------|------|------|
| 레이아웃 패턴 | Header + Controls + Content 3단 구조 | 스크롤 없이 한 화면에 보여야 하는 요구사항 |
| 헤더 sticky | sticky 채택 (`position: sticky; top: 0`) | 모바일에서 긴 콘텐츠 스크롤 시 제목 맥락 유지 |
| 컨트롤 바 구성 | "전체 보기" 버튼(1) + 단 선택 버튼 그룹(8) | 명세 §4-1 명시 구조 그대로 반영 |
| "전체 보기" 버튼 상태 | 모드 A에서 disabled, 모드 B에서 활성 | 명세 §4-1 명시 |
| 카드 hover scale-up | 포함 (`transform: translateY(-2px)`) | 명세 §6-3 권장 사항, UX 완성도 향상 |
| 카드 클릭 — 모드 B 전환 | 포함 | 명세 §3-2 필수 요건 |
| 페이지 부제목 | 없음 | 스펙에 h1 "구구단"만 명시, 부제목 불필요 판단 |
| 색상 팔레트 | 단별 HSL 팔레트 (8가지 구분색) | 이전 설계 계승, 8가지 구분·접근성 확보 |
| 카드 그리드 | CSS Grid, auto-fill + minmax | 반응형 자동 열 계산, 미디어쿼리 최소화 |

---

## 2. 미확정 사항 결정

### 2-1. 헤더 sticky 여부
**결정: sticky 채택**
- `position: sticky; top: 0; z-index: 100`
- 배경에 `backdrop-filter: blur(4px)` 또는 불투명 배경(`#f5f6fa`) 적용하여 콘텐츠 겹침 방지
- 근거: 모바일(360px)에서 카드 스크롤 시 페이지 맥락 유지

### 2-2. 카드 hover scale-up 여부
**결정: 포함**
- `transform: translateY(-2px)` + `box-shadow 강화` 조합
- scale() 대신 translateY 사용 이유: 그리드 셀 크기 변동 없이 부상 효과 제공
- 빠른 단 전환 시 레이아웃 안정성 보장

### 2-3. 페이지 부제목 여부
**결정: 없음**
- h1 "구구단"만 표시
- 부제목 추가는 태스크 발행자 요청이 있을 때만 반영

---

## 3. 색상 팔레트

### 단별 색상 (HSL 기반)

| 단 | 이름 | Card BG | Card Border | Button Active BG | Button Text |
|----|------|---------|-------------|------------------|-------------|
| 2단 | Sky Blue | hsl(210, 85%, 94%) | hsl(210, 75%, 55%) | hsl(210, 75%, 55%) | #fff |
| 3단 | Mint Green | hsl(150, 70%, 92%) | hsl(150, 60%, 42%) | hsl(150, 60%, 42%) | #fff |
| 4단 | Coral | hsl(20, 90%, 94%) | hsl(20, 80%, 58%) | hsl(20, 80%, 58%) | #fff |
| 5단 | Violet | hsl(270, 75%, 94%) | hsl(270, 65%, 58%) | hsl(270, 65%, 58%) | #fff |
| 6단 | Amber | hsl(40, 90%, 92%) | hsl(40, 80%, 50%) | hsl(40, 80%, 50%) | #1a1a1a |
| 7단 | Rose | hsl(340, 80%, 94%) | hsl(340, 70%, 58%) | hsl(340, 70%, 58%) | #fff |
| 8단 | Teal | hsl(180, 70%, 92%) | hsl(180, 60%, 40%) | hsl(180, 60%, 40%) | #fff |
| 9단 | Indigo | hsl(230, 75%, 94%) | hsl(230, 65%, 55%) | hsl(230, 65%, 55%) | #fff |

> 6단(Amber)만 텍스트를 어두운 색으로 설정 — 밝은 황색 배경에서 WCAG 대비율 4.5:1 확보

### 중립 색상 (CSS 변수)

```
--color-bg:          #f5f6fa     /* 페이지 배경 */
--color-surface:     #ffffff     /* 카드/패널 기본 배경 */
--color-text:        #1a1a2e     /* 본문 텍스트 */
--color-text-muted:  #6b7280     /* 보조 텍스트 */
--color-btn-bg:      #e8e9f0     /* 비활성 버튼 배경 */
--color-btn-text:    #374151     /* 비활성 버튼 텍스트 */
--color-border:      #d1d5db     /* 일반 테두리 */
--color-shadow:      rgba(0,0,0,0.10)
--color-disabled-bg: #c9cad0     /* 전체 보기 버튼 disabled 배경 */
--color-disabled-text: #9ca3af  /* disabled 텍스트 */
```

---

## 4. 타이포그래피

```
폰트 스택 (UI): -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
수식 폰트:      'Courier New', Courier, 'Lucida Console', monospace

h1 (페이지 제목)  : 2.0rem / 700 / color-text / letter-spacing: -0.02em
카드 제목(N단)    : 1.25rem / 700 / 단별 border 색
수식 행           : 1.0rem  / 400 / color-text / monospace / line-height: 2.0
버튼 레이블       : 0.95rem / 600 / 각 단 색상 또는 color-btn-text
```

---

## 5. 레이아웃

### 5-1. 전체 구조 — 데스크톱 (≥768px)

```
┌─────────────────────────────────────────────────────────┐
│  HEADER (sticky)                                        │
│  h1: 구구단 — text-align: center | padding: 24px 16px  │
│  background: #f5f6fa | z-index: 100                     │
├─────────────────────────────────────────────────────────┤
│  CONTROL BAR                                            │
│  [ 전체 보기 ]   [ 2 ][ 3 ][ 4 ][ 5 ][ 6 ][ 7 ][ 8 ][ 9 ] │
│  display: flex | gap: 8px | justify-content: center     │
│  padding: 16px 16px 24px                                │
├─────────────────────────────────────────────────────────┤
│  CONTENT AREA                                           │
│  모드 A: CSS Grid 4열 | 모드 B: 단일 카드 중앙 배치     │
│  padding: 0 24px 32px                                   │
└─────────────────────────────────────────────────────────┘
```

컨트롤 바 내부 배치:
```
[ 전체 보기 버튼 ]  |  [ 2 ][ 3 ][ 4 ][ 5 ][ 6 ][ 7 ][ 8 ][ 9 ]
    .ctrl-all-btn       .dan-btn-group (flex, gap: 6px)
```

구분선(border-right 또는 divider) 또는 gap(16px)으로 두 그룹을 시각적으로 분리.

### 5-2. 모드 A — 전체 보기 그리드

```
display: grid
grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))
gap: 16px
max-width: 960px
margin: 0 auto
padding: 0 24px 32px
```

데스크톱(≥768px)에서 200px minmax → 자연스럽게 4열 형성.

### 5-3. 모드 B — 단 선택 보기

```
display: flex
justify-content: center
padding: 0 24px 32px

.table-card--selected {
  width: 100%;
  max-width: 480px;
  padding: 32px 40px;
  border-width: 4px;
  /* 단별 색상 + 강화된 그림자 */
}

수식 행 font-size: 1.25rem (모드 A의 1.0rem보다 크게)
```

---

## 6. 컴포넌트 명세

### 6-1. "전체 보기" 버튼 (.ctrl-all-btn)

```
기본 상태 (모드 B — 클릭 가능):
  background: var(--color-btn-bg)
  color: var(--color-btn-text)
  border: 2px solid transparent
  border-radius: 8px
  padding: 8px 16px
  font-size: 0.95rem
  font-weight: 600
  cursor: pointer
  transition: background 0.15s, transform 0.1s

hover (모드 B):
  background: var(--color-text)
  color: #ffffff
  transform: translateY(-1px)

active (누를 때):
  transform: translateY(0)

disabled 상태 (모드 A):
  background: var(--color-disabled-bg)
  color: var(--color-disabled-text)
  cursor: not-allowed
  opacity: 0.6
  pointer-events: none
  /* HTML: disabled 속성 + aria-disabled="true" */
```

> 이 버튼은 단별 색상을 사용하지 않는다. 어떤 단도 선택되지 않은 상태(모드 A)에서는 기능 없음을 명확히 표시.

### 6-2. 단 선택 버튼 (.dan-btn)

```
기본 상태 (비활성):
  background: var(--color-btn-bg)
  color: var(--color-btn-text)
  border: 2px solid transparent
  border-radius: 8px
  padding: 8px 14px
  font-size: 0.95rem
  font-weight: 600
  cursor: pointer
  transition: background 0.15s, transform 0.1s

hover 상태:
  background: hsl(var(--dan-hue), 75%, 55%, 0.2)
  /* 단별 색상 20% opacity — data-dan 속성으로 CSS var 참조 */
  transform: translateY(-1px)

active (누를 때):
  transform: translateY(0)

선택된 상태 (.dan-btn--active):
  background: var(--dan-border)    /* 단별 진한 색 */
  color: var(--dan-btn-text)       /* 단별 텍스트 색 (흰색 또는 어두운 색) */
  border-color: var(--dan-border)
  font-weight: 700
  box-shadow: 0 2px 8px var(--color-shadow)

모드 A에서:
  어떤 .dan-btn도 .dan-btn--active 클래스를 갖지 않음
  (모드 A = 전체 보기 상태이므로 특정 단 선택 없음)

접근성:
  role="button" 또는 <button> 요소
  aria-pressed="true" (선택된 단 버튼)
  aria-pressed="false" (비활성 단 버튼)
  tabindex: 0
  :focus-visible { outline: 2px solid var(--dan-border); outline-offset: 2px }
```

### 6-3. 단 카드 (.table-card)

```
기본 상태 (모드 A):
  background: var(--dan-bg)
  border: 2px solid var(--dan-border)
  border-radius: 12px
  padding: 20px
  box-shadow: 0 2px 6px var(--color-shadow)
  transition: box-shadow 0.15s, transform 0.15s
  cursor: pointer

hover 상태 (모드 A):
  box-shadow: 0 6px 20px var(--color-shadow)
  transform: translateY(-2px)

active (누를 때):
  transform: translateY(0)
  box-shadow: 0 2px 6px var(--color-shadow)

선택된 상태 (모드 B의 단일 카드, .table-card--selected):
  border-width: 4px
  box-shadow: 0 8px 24px hsl(/* dan-border hue */ 75%, 55%, 30%)
  cursor: default  /* 이미 선택된 카드 — 재클릭 불필요 */

카드 제목 (.table-card__title):
  font-size: 1.25rem
  font-weight: 700
  color: var(--dan-border)
  margin-bottom: 12px

수식 목록 (.table-card__list):
  list-style: none
  padding: 0
  margin: 0

접근성 (모드 A의 클릭 가능한 카드):
  role="button"
  aria-label="N단 보기"
  tabindex: 0
  :focus-visible { outline: 2px solid var(--dan-border); outline-offset: 3px }

접근성 (모드 B의 선택된 카드):
  aria-current="true" 또는 role="region" + aria-label="N단"
  tabindex: -1 (포커스 불필요)
```

### 6-4. 수식 행 (.formula-item)

```html
<!-- 마크업 예시 (명세 목적 스니펫) -->
<li class="formula-item">
  <span class="formula-item__num">2</span>
  <span class="formula-item__op">&times;</span>
  <span class="formula-item__num">3</span>
  <span class="formula-item__eq">=</span>
  <span class="formula-item__result">6</span>
</li>
```

```css
/* CSS 예시 */
.formula-item {
  display: grid;
  grid-template-columns: 2ch 1.5ch 2ch 1.5ch 3ch;
  gap: 2px;
  align-items: center;
  font-family: 'Courier New', Courier, monospace;
  font-size: 1.0rem;   /* 모드 A */
  line-height: 2.0;
}
/* 모드 B에서 선택된 카드 내 수식 */
.table-card--selected .formula-item {
  font-size: 1.25rem;
}
.formula-item__num,
.formula-item__op,
.formula-item__eq,
.formula-item__result {
  text-align: right;
}
```

grid-template-columns를 고정 ch 단위로 쓰면 N, ×, M, =, R 각 컬럼이 모든 식에서 수직 정렬됨.

### 6-5. 헤더 (.page-header)

```
position: sticky
top: 0
z-index: 100
background: #f5f6fa   /* 또는 rgba(245,246,250,0.95) + backdrop-filter: blur(4px) */
text-align: center
padding: 24px 16px 16px

h1.page-header__title {
  font-size: 2.0rem;
  font-weight: 700;
  color: var(--color-text);
  margin: 0;
  letter-spacing: -0.02em;
}
```

### 6-6. 컨트롤 바 (.control-bar)

```
display: flex
flex-wrap: wrap
align-items: center
justify-content: center
gap: 8px
padding: 16px 16px 24px
background: #f5f6fa   /* 헤더와 동일 배경 — sticky 시 연속감 */

.control-bar__divider {
  width: 1px;
  height: 24px;
  background: var(--color-border);
  margin: 0 4px;
  /* 두 그룹(전체 보기 / 단 버튼)을 시각적으로 분리 */
}

.dan-btn-group {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
```

### 6-7. 콘텐츠 영역 (.content-area)

```
모드 A (.content-area--all):
  display: grid
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))
  gap: 16px
  max-width: 960px
  margin: 0 auto
  padding: 0 24px 32px

모드 B (.content-area--single):
  display: flex
  justify-content: center
  padding: 0 24px 32px
```

---

## 7. 인터랙션 & 상태 전이

```
초기 로드
  → 모드 A 활성
  → .ctrl-all-btn: disabled / aria-disabled="true"
  → 단 버튼 모두 비활성 (aria-pressed="false")
  → 8개 카드 모두 표시

단 버튼(2~9) 클릭
  → 이전 .dan-btn--active 클래스 제거 + aria-pressed="false"
  → 클릭한 .dan-btn에 .dan-btn--active + aria-pressed="true"
  → .ctrl-all-btn disabled 해제
  → .content-area: .content-area--all → .content-area--single
  → 해당 단 카드만 표시 (.table-card--selected 추가)

"전체 보기" 버튼 클릭 (모드 B에서만 가능)
  → 모든 .dan-btn--active 제거 + aria-pressed="false"
  → .ctrl-all-btn disabled 재설정
  → .content-area: .content-area--single → .content-area--all
  → 8개 카드 모두 표시

모드 A에서 카드 클릭
  → 해당 단의 단 버튼 클릭과 동일한 동작
  → 해당 단 버튼에 .dan-btn--active + aria-pressed="true"
  → 모드 B로 전환

모드 B에서 다른 단 버튼 클릭
  → 이전 .dan-btn--active 제거
  → 새 .dan-btn--active 추가
  → 표시 단 카드 교체 (모드는 B 유지)

모드 전환 시:
  window.scrollTo(0, 0) 로 스크롤 초기화
  즉시 전환 (setTimeout 사용 금지)
  권장: .content-area에 opacity 0→1 전환 0.1s (간단 페이드만 허용)
```

---

## 8. 반응형 레이아웃

### 미디어쿼리 요약

```css
/* 기본 (모바일 우선, < 480px) */
.content-area--all {
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  padding: 0 12px 24px;
}
.ctrl-all-btn { padding: 6px 12px; font-size: 0.875rem; }
.dan-btn       { padding: 6px 10px; font-size: 0.875rem; }
.control-bar__divider { display: none; }  /* 소형에서 구분선 제거 */

/* 컨트롤 바 소형: 전체 보기 버튼이 위, 단 버튼 그룹이 아래 줄 */
.control-bar { flex-direction: column; align-items: center; gap: 10px; }
.dan-btn-group { justify-content: center; }

@media (min-width: 480px) {
  .content-area--all {
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 14px;
    padding: 0 16px 28px;
  }
  .control-bar { flex-direction: row; }
  .control-bar__divider { display: block; }
}

@media (min-width: 768px) {
  .content-area--all {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 16px;
    padding: 0 24px 32px;
    max-width: 960px;
    margin: 0 auto;
  }
  .ctrl-all-btn { padding: 8px 16px; font-size: 0.95rem; }
  .dan-btn       { padding: 8px 14px; font-size: 0.95rem; }
}
```

### 뷰포트별 레이아웃 정리

| 뷰포트 | 컨트롤 바 | 모드 A 카드 열 수 |
|--------|----------|-----------------|
| < 480px | 전체 보기 위, 단 버튼 아래 (2행) | 2열 |
| 480~767px | 1행 좌우 배치 (flex-wrap 허용) | 2~3열 (auto-fill) |
| ≥ 768px | 1행 수평 배치 | 4열 |

---

## 9. CSS 변수 구조 (coder 구현 참고)

```css
:root {
  /* 중립 */
  --color-bg:           #f5f6fa;
  --color-surface:      #ffffff;
  --color-text:         #1a1a2e;
  --color-text-muted:   #6b7280;
  --color-btn-bg:       #e8e9f0;
  --color-btn-text:     #374151;
  --color-border:       #d1d5db;
  --color-shadow:       rgba(0, 0, 0, 0.10);
  --color-disabled-bg:  #c9cad0;
  --color-disabled-text:#9ca3af;
}

/* 단별 CSS Custom Properties — data-dan 속성으로 스코프 */
[data-dan="2"] { --dan-bg: hsl(210,85%,94%); --dan-border: hsl(210,75%,55%); --dan-btn-text: #fff; }
[data-dan="3"] { --dan-bg: hsl(150,70%,92%); --dan-border: hsl(150,60%,42%); --dan-btn-text: #fff; }
[data-dan="4"] { --dan-bg: hsl(20,90%,94%);  --dan-border: hsl(20,80%,58%);  --dan-btn-text: #fff; }
[data-dan="5"] { --dan-bg: hsl(270,75%,94%); --dan-border: hsl(270,65%,58%); --dan-btn-text: #fff; }
[data-dan="6"] { --dan-bg: hsl(40,90%,92%);  --dan-border: hsl(40,80%,50%);  --dan-btn-text: #1a1a1a; }
[data-dan="7"] { --dan-bg: hsl(340,80%,94%); --dan-border: hsl(340,70%,58%); --dan-btn-text: #fff; }
[data-dan="8"] { --dan-bg: hsl(180,70%,92%); --dan-border: hsl(180,60%,40%); --dan-btn-text: #fff; }
[data-dan="9"] { --dan-bg: hsl(230,75%,94%); --dan-border: hsl(230,65%,55%); --dan-btn-text: #fff; }
```

---

## 10. 클래스 네이밍 구조 (BEM 스타일)

```
.page-header
  .page-header__title          ← h1

.control-bar
  .ctrl-all-btn                ← "전체 보기" 버튼 (disabled 상태 포함)
  .control-bar__divider        ← 시각적 구분선
  .dan-btn-group               ← 단 버튼 컨테이너
    .dan-btn                   ← 단 버튼 기본
    .dan-btn--active           ← 현재 선택된 단 버튼

.content-area
  .content-area--all           ← 모드 A 그리드
  .content-area--single        ← 모드 B 단일 카드

.table-card                    ← 단 카드 (data-dan="N" 속성 포함)
  .table-card--selected        ← 모드 B에서 표시 중인 카드
  .table-card__title           ← "N단" 제목
  .table-card__list            ← ul

.formula-item                  ← 개별 수식 행 (li)
  .formula-item__num           ← N, M 숫자
  .formula-item__op            ← × 기호
  .formula-item__eq            ← = 기호
  .formula-item__result        ← 결과 R
```

---

## 11. 빈/오류/로딩 상태

외부 데이터 없는 순수 클라이언트 사이드 연산. 별도 로딩·오류 상태 없음.

예외: JS 비활성 환경 → `<noscript>` 태그로 "JavaScript가 필요합니다" 텍스트 표시 권장.

---

## 12. 접근성 체크리스트

| 항목 | 구현 방법 |
|------|---------|
| 키보드 탭 이동 | .ctrl-all-btn, .dan-btn, .table-card 모두 tabindex=0 |
| Enter/Space 활성화 | `<button>` 요소 사용 (기본 동작) 또는 keydown 핸들러 |
| 색상 외 상태 구분 | aria-pressed="true" + font-weight: 700 + 테두리 강조 병행 |
| disabled 상태 명시 | .ctrl-all-btn: disabled 속성 + aria-disabled="true" |
| 포커스 표시 | :focus-visible outline 명시 (reset CSS에서 제거 금지) |
| 카드 역할 명시 | role="button" + aria-label="N단 보기" (모드 A) |
| 선택된 카드 | aria-current="true" + role="region" + aria-label="N단" (모드 B) |
| 수식 의미 전달 | aria-label="N 곱하기 M 은 R" (선택 사항, 구현 비용 감안) |

---

## 13. coder 구현 주의사항

1. **"전체 보기" 버튼 disabled 처리**
   HTML `disabled` 속성과 `aria-disabled="true"` 둘 다 사용.
   JS에서 모드 전환 시 반드시 disabled 속성 추가/제거.

2. **단 버튼 aria-pressed 관리**
   모드 A 진입 시: 모든 .dan-btn의 aria-pressed="false".
   단 버튼 클릭 시: 이전 활성 버튼 aria-pressed="false" → 새 버튼 aria-pressed="true".

3. **data-dan 속성 범위**
   .dan-btn과 .table-card 모두에 data-dan="N" 부여.
   CSS var(--dan-bg), var(--dan-border), var(--dan-btn-text)가 이 속성에서 상속됨.

4. **모드 전환 애니메이션**
   opacity 0→1 0.1s 페이드만 허용.
   transform 애니메이션은 빠른 단 전환 시 레이아웃 충돌 우려로 제외.

5. **카드 높이**
   모드 A에서 모든 카드가 동일 높이(9행). height 고정 불필요.
   grid-auto-rows 설정 시 더 안정적인 그리드 유지 가능.

6. **소형 모바일(< 480px) 컨트롤 바**
   `flex-direction: column` 으로 전체 보기 버튼이 위, 단 버튼 그룹이 아래 배치.
   구분선(.control-bar__divider)은 이 뷰포트에서 `display: none`.

7. **가로 스크롤 방지**
   `body { overflow-x: hidden }` 또는 `max-width: 100vw` 전체 적용.

---

## 14. 미해결 이슈

없음. 이전 설계(t_d2dc073e)의 미확정 사항을 모두 이번에 결정했음.

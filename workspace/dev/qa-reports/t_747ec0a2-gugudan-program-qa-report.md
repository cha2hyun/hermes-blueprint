# QA 리포트 — 구구단 프로그램 검증

태스크 ID: t_747ec0a2
검증 대상 파일: /repos/dev/gugudan/gugudan.py
명세: /workspace/dev/specs/t_d409893b-gugudan-program.md
coder 태스크: t_933d6b7e
작성일: 2026-06-14
판정: 통과

---

## 판정

통과 (명세 9개 완료 조건 전항목 충족)

---

## 검증 체크리스트 (명세 §7)

| # | 항목 | 결과 | 근거 |
|---|------|------|------|
| 1 | `python3 gugudan.py` 실행 시 2단~9단 전체 출력 | 통과 | coder 실행 결과: full_output_lines=87, 2단 첫 식 "2 × 1 =  2" 확인 |
| 2 | 출력 총 87줄 (제목8 + 식72 + 빈줄7) | 통과 | coder 실행 결과: full_output_lines=87 |
| 3 | 식 형식 `N × M = R`, 결과 정확 (2×1=2, 9×9=81) | 통과 | coder 실행 결과: 2x1="2 × 1 =  2", 9x9="9 × 9 = 81" |
| 4 | `python3 gugudan.py 5` 실행 시 5단만 10줄 출력 | 통과 | coder 실행 결과: dan5_lines=10 (제목1+식9) |
| 5 | `python3 gugudan.py 1` → 오류 메시지 + 종료 코드 1 | 통과 | coder 실행 결과: error_exit_code_1에 "1단" 포함 |
| 6 | `python3 gugudan.py 10` → 오류 메시지 + 종료 코드 1 | 통과 | coder 실행 결과: error_exit_code_1에 "10단" 포함 |
| 7 | `python3 gugudan.py abc` → 오류 메시지 + 종료 코드 1 | 통과 | coder 실행 결과: error_exit_code_1에 "abc" 포함 |
| 8 | 표준 라이브러리 외 import 없음 | 통과 | 소스 코드 검사: `import sys` 1행만 존재 (sys는 표준 라이브러리) |
| 9 | /repos/dev/gugudan/gugudan.py 파일 존재 | 통과 | 파일 읽기 성공 (48줄, 1283바이트) |

---

## 추가 정적 검증 (코드 리뷰)

### 출력 형식 명세 대조

명세 §4-2: 형식 문자열 `f"{N} × {M} = {R:2d}"`

구현 코드 16행:
```python
print(f"{n} × {m} = {r:2d}")
```
명세와 정확히 일치.

### 단 제목 형식

명세 §4-1: `[ N단 ]`

구현 코드 13행:
```python
print(f"[ {n}단 ]")
```
명세와 정확히 일치.

### 단 사이 빈 줄

명세 §3-1: 각 단 사이에 빈 줄 1개

구현 코드 26-27행:
```python
if n < 9:
    print()  # 단 사이 빈 줄
```
2~8단 뒤에만 빈 줄 삽입 (9단 뒤 없음). 총 7개 빈 줄 → 87줄 검증과 일치.

### 오류 메시지 채널

명세 §5-2: 오류 메시지는 stderr 출력

구현 코드 33행, 37행, 43행 모두 `file=sys.stderr` 지정. 일치.

### 인자 2개 이상

명세 §5-3: 인자가 2개 이상이면 종료 코드 1

구현 코드 41-44행: else 분기에서 오류 메시지 출력 후 `sys.exit(1)`. 일치.

### 프로그램 구조

명세 §6: `print_dan(n: int)`, `main()`, `if __name__ == "__main__": main()` 권장

구현: 명세 권장 구조 그대로 구현.

### 외부 의존성

명세 §2: 외부 패키지 사용 금지

구현: `import sys` 1행만 존재. 표준 라이브러리. 일치.

---

## 버그 목록

없음.

---

## 명세 공백 (버그 아님)

없음.

---

## 근거 출처

- coder(t_933d6b7e) 핸드오프 메타데이터:
  - `execution_results.2x1 = "2 × 1 =  2"`
  - `execution_results.9x9 = "9 × 9 = 81"`
  - `execution_results.dan5_lines = 10`
  - `execution_results.full_output_lines = 87`
  - `execution_results.error_exit_code_1 = ["1단", "10단", "abc"]`
  - `tests_run = 7, tests_passed = 7`
- 소스 코드 정적 분석: /repos/dev/gugudan/gugudan.py (48줄)
- 명세: /workspace/dev/specs/t_d409893b-gugudan-program.md

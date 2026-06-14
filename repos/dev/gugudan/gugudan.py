"""구구단 프로그램 — 2단~9단 출력 CLI

사용법:
    python3 gugudan.py        # 2단~9단 전체 출력
    python3 gugudan.py N      # N단만 출력 (N: 2~9)
"""

import sys


def print_dan(n: int) -> None:
    """n단의 제목과 9개 식을 stdout에 출력한다."""
    print(f"[ {n}단 ]")
    for m in range(1, 10):
        r = n * m
        print(f"{n} × {m} = {r:2d}")


def main() -> None:
    args = sys.argv[1:]

    if len(args) == 0:
        # 전체 출력 (2단~9단)
        for n in range(2, 10):
            print_dan(n)
            if n < 9:
                print()  # 단 사이 빈 줄
    elif len(args) == 1:
        # 단 지정
        try:
            n = int(args[0])
        except ValueError:
            print(f"오류: 단은 2~9 사이의 정수여야 합니다. (입력값: {args[0]})", file=sys.stderr)
            sys.exit(1)

        if n < 2 or n > 9:
            print(f"오류: 단은 2~9 사이의 정수여야 합니다. (입력값: {n})", file=sys.stderr)
            sys.exit(1)

        print_dan(n)
    else:
        # 인자가 2개 이상
        print(f"오류: 단은 2~9 사이의 정수여야 합니다. (입력값: {' '.join(args)})", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

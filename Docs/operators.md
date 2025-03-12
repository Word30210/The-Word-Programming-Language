# Operators

연산자는 값을 변경, 비교 또는 결합하는 데 사용하는 특수 기호 또는 구문입니다.
Word에서는 대부분의 Lua5.2의 연산자를 지원합니다.

## 산술 연산자
- 덧셈 (+)
- 뺄셈 (-)
- 곱셈 (*)
- 나눗셈 (/)
- 나머지 계산 (%)
- 몫 계산 (//)
```lua
var n1 = 1 + 2 -- equals 3
var n2 = 5 - 3 -- equals 2
var n3 = 2 * 3 -- equals 6
var n4 = 10 / 2.5 -- equals 4
var n5 = 9 % 4 -- equals 1
var n6 = 9 // 4 -- equals 2
```

## 할당 연산자
할당 연산자 `=` 은 값을 초기화하거나 업데이트합니다.
```lua
var a = 50; -- a = 50
var b = a; -- b = 50
var c = a * b -- c = 50 * 50
```

## 비교 연산자
비교 연산자는 Boolean값을 반환하여 statement가 참인지 거짓인지 여부를 나타냅니다.

- 일치 계산 (==)
- 불일치 계산 (!=)
- 작다 계산 (<)
- 작거나 같다 계산 (<=)
- 크다 계산 (>)
- 크거나 같다 계산 (>=)

```lua
1 == 1 -- true because 1 is equal to 1
1 != 2 -- true because 1 is not equal to 2
1 < 2 -- true because 1 is less than 2
1 <= 1 -- true because 1 is less than or equal to 1
1 > 2 -- false because 1 is not greater than 2
1 >= 2 -- true because 1 is greater than or equal to 2
```

## 논리 연산자
논리 연산자는 비교 연산자와 같이 Boolean값을 반환하여 statement가 참인지 거짓인지 여부를 나타냅니다.

- 논리 NOT (!)
- 논리 AND (&)
- 논리 OR (|)

```lua
!1 -- false because 1 is true
1 & false -- false because one of the two values is false
true | none -- true because one of the two values if true
```

## 복합 할당 연산자
할당 연산자와 산술연산자의 결합입니다.

- 더하고 할당 (+=)
- 빼고 할당 (-=)
- 곱하고 할당 (*=)
- 나누고 할당 (/=)
- 나머지 계산하고 할당 (%=)
- 몫 계산하고 할당 (//=)

## 기타 연산자

- 문자열, 배열의 길이 (#)
- 부호 반전, 문자열과 배열 순서 반전 (-)
- 문자열 결합 (..)
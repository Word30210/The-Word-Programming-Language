# Data Types
**Word**에는 다양한 자료형(Data Type)이 존재합니다.

## number
Word는 동적 프로그래밍 언어이기 때문에, 정적 프로그래밍 언어에 존재하는 `int`, `float` 등의 자료형은 모두 `number` 로 취급됩니다.

```lua
var n1 = 123 -- decimal
var n2 = 0xFF -- hexadecimal
var n3 = 0O7777 -- octal
var n4 = 0B0101 -- binary

var n5 = 0.123 -- minority
var n6 = .123 -- another minority
```

## string
문자열은 불변의 문자 시퀀스입니다.
문자열 리터럴은 이중 또는 단일 따옴표로 둘러싸여 있을 수 있습니다.
```lua
var str1 = "Hello, world!" -- double quotes
var str2 = 'Hello, world!' -- single quotes

var multilineString = [[
    this
    is
    a
    multi-line
    string
]]

var multilineStringLv2 = [==[
    this
    is
    [[
        a
        multi-line
    ]]
    [=[
        [[
            string
        ]]
    ]=]
]==]

var len = #str1 -- len is 13
var reversed = -str1 -- reversed is "!dlrow ,olleH"

var interpolation = 'print("\(str1)")' -- print("Hello, world!")

var multilineInterpolation = [[
    var str1 = "\(str1)" -- double quotes
    var str2 = '\(str2)' -- single quotes
]]
```

## Boolean
진리값 데이터 유형은 두 개의 값만 존재하며, 리터럴은 `true` 및 `false` 입니다.
진리값은 조건의 유효성을 나타냅니다.(조건이 참인지 거짓인지 여부)

```lua
var a = true;
var b = false;
```

## None
Word에서 값이 없음은 `none` 리터럴을 사용하요 나타냅니다.
아무것도 반환하지 않는 함수(혹은 statement-expression)를 호출하고 반환된 값을 얻으면 `none` 을 얻습니다.

없음값 데이터 형식은 변수를 초기화하는 데에 사용될 수 있습니다.

```lua
var printHelloWorld = fn()
{
    stdio.output("Hello, world!")
}

var result = printHelloWorld()

-- prints none
stdio.output(result)
```

## Array
배열은 간단한 개체 시퀀스이고, 크기는 당연히 동적이며, 인덱스는 항상 **1**에서 시작합니다.

배열 리터럴은 대괄호로 싸여있습니다.

```lua
var arr1 = [ 1, 2, 3, 4, 5 ]
var arr2 = [ 1, 1, 2, 3, 5, 8, 13 ]

-- prints '1'
stdio.output(arr1[1])

-- prints array [ 1, 1, 2, 3, 5, 8, 13 ]
stdio.output(arr2)

var len = #arr1 -- len is 5
var reversed = -arr1 -- reversed is [ 13, 8, 5, 3, 2, 1, 1 ]

var negativeIndex = arr1[-1] -- negativeIndex is 5
var negativeIndex2 = (-arr1)[1] -- negativeIndex2 is equal to negativeIndex
```

## Dictionary
사전은 각각 값에 키를 매핑하는 쌍으로 구현된 컨테이너입니다.

아래와 같이 작성합니다.

```lua
var dict = {
    ["Apple"] = 5; -- Separated by semicolon
    ["Banana"] = 2;
    ["Coconut"] = 1; -- The final semicolon is optional
}
```
키는 무조건 문자열이여야 합니다.

사전에 들어있는 값을 가져오려면 아래와 같이 작성합니다.

```lua
-- prints '5'
stdio.output(dict["Apple"])
```

사전에 값을 추가하거나 제거하려면 아래와 같이 작성합니다.

```lua
dict["Watermelon"] = 2

dict["Banana"] = none
```
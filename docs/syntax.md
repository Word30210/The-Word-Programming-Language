# Syntax

**Word**의 문법은 C, Lua, Ruby를 참고하여 디자인 되었습니다.

Word 코드는 다음과 같습니다.
```lua
class Rectangle(var width, height)
{
    -- instance variables
    var width = width | 0
    var height = height | 0

    -- instance method
    var area = fn()
    {
        return @@.width * @@.height
    }
}

var r = Rectangle(20, 10)

stdio.output(r.area())
```

## Comment
Word의 한줄, 여러줄 주석을 모두 지원합니다.
```lua
-- this is a line comment
```
```lua
--[[
    this
    is
    a
    multi-line
    comment
]]

--[==[
    this
    is
    [[
        a
        multi-line
    ]]
    [=[
        comment
    ]=]
]==]
```

# Import
다른 Word파일 내에서 Word파일을 불러오려면 `require("path/to/other/word/file.word")` 라는 내장 함수를 사용할 수 있습니다.
```lua
-- adder.word
var add = fn(var x, y)
{
    return x + y
}

return add
```
```lua
var add = require("adder.word")

stdio.output("5 + 4 = " .. add(5, 4))
```

# Reserved Keywords
다른 많은 프로그래밍 언어와 마찬가지로 Word에는 소스 코드의 컨텍스트에서 매우 구체적인 의미를 가정하는 몇 가지 예약 된 키워드가 있습니다.
```lua
var fn class if elif else switch case default for while each true false none continue break return
```

# Identifiers / Variables
식별자(Identifier)는 소스 코드 내에 개체를 식별하는 데 사용되는 명명 규칙을 나타냅니다.
식별자는 문자 또는 밑줄(_)로 시작하여 문자, 숫자 및 밑줄을 포함할 수 있습니다.

그리고 당연하게도 모든 변수의 이름은 식별자로 구성되어 있습니다.
```lua
a
_thisIsValid
Hello_World
foo123
BYE_BYE
```

# Blocks and Scope
소스 코드에 선언된 모든 변수는 스코프에 포함됩니다.
스코프는 해당 스코프에 포함된 변수들이 존재할 수 있는 소스 코드의 가장 큰 부분입니다.

스코프는 중괄호 `{, }` 로 구분합니다.
```lua
var a = 1

-- block scope can be nested and
-- can hide other local variables
{
    var a = 2
}

-- prints number '1'
stdio.out(a)
```
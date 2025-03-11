# The Word Programming Language

**Word** 언어는 Luau로 작성된, 동적 스크립트 언어입니다.
**Word**는 다중 패러다임 언어로, 객체 지향(Object Oriented), 함수형 프로그래밍(Functional Programming), 식 지향(Expression Oriented)을 지원합니다.

**! 현재 Word의 문법은 디자인 단계로, 추후 문법 일부가 변경될 수 있습니다 !**

# What Word code looks like
```lua
var Vector = class(var x, y, z)
{
    -- istance variables
    var x = x | 0
    var y = y | 0
    var z = z | 0

    -- magic variable, __type__ (set class type to "Vector") (Optional, default class type is "class{UUID}")
    var __type__ = "Vector"

    -- magic methods (built-in operator overriding)
    var __add__ = fn(var rhs)
    {
        return @(@@.x + rhs.x, @@.y + rhs.y, @@.z + rhs.z)
    }

    var __sub__ = fn(var rhs)
    {
        return @(@@.x - rhs.x, @@.y - rhs.y, @@.z - rhs.z)
    }

    var __str__ = fn()
    {
        return "[\(x),\(y),\(z)]"
    }
}

-- initialize a new vector objects
var v1 = Vector(1, 2, 3)
var v2 = Vector(4, 5, 6)

-- call __add__ magic mathod in the vector object
var v3 = v1 + v2

-- prints string "[1,2,3] + [4,5,6] = [5,7,9]"
stdio.output("\(v1) + \(v2) = \(v3)")
```

# Features

# Language Guide
- [Syntax](docs/syntax.md)
- [Operators](docs/operators.md)
- [Data Types](docs/dataTypes.md)
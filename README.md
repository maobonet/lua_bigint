# lua_bigint
big integer for lua

## Usage
```lua
local lbigint = require "lua_bigint"

local i0 = lbigint(10000000) -- construct from integer
local i1 = lbigint("-10000000") -- construct from string
local i2 = lbigint("0xFFFFFFFFFF") -- construct from hex string
local i3 = lbigint(i0) -- construct from other bigint

i0:assign(10000000) -- assign from integer
i1:assign("-10000000") -- assign from string
i2:assign("0xFFFFFFFFFF") -- assign from hex string
i3:assign(i0) -- assign from other bigint

tostring(i0) -- 10000000

-- get pointer address, typically this function is used only
-- for hashing and debug information
i0:to_pointer() -- 93943009449888

i0:set_const(true) -- set as const(immutable)

assert(lbigint(100) == lbigint(100)) -- test equal
-- test equal with diffrent type, meta method __eq never get called,
-- the result is always false, however, equal can be called manually
assert(lbigint(100) ~= 100)
assert(lbigint(100):equal(100))
assert(lbigint(100):equal("100"))
assert(lbigint(100):equal(lbigint(100)))

-- test sign
assert(lbigint(0) == 0)
assert(lbigint(1) == 1) -- >0 return 1
assert(lbigint(-1) == -1) -- <0 return -1

-- arithmetic + - * /

```

## Mutable
Usually variables in arithmetic are immutable, e.g.
```lua
local a = 100
local b = 50

local c = a + b -- this is it, a still 100 and b still 50
```
this is very efficient. But when it comes to big integer, can be very slow, e.g.
```lua
local a = lbigint("100000000000000...") -- a 10000-0 long string
a = a + 1
```
If `a` is immutable, a temporary variable will be cloned from `a`, and the cloned
process is quit slow. in this case the `a` is expected to be mutable, the cloned
is total waste of time.

As default, in any big integer arithmetic, variables are all mutable, unless they
are immutable(use `set_const(true)`) or create a temporary variable manually. e.g.
```lua
local a = lbigint("1000000000")

local d = lbigint(a) + 10000000 -- create a temporary variable manually

a:set_const(true)
local c = a + 1000000 -- a still 1000000000
```

## TODO
```cpp
    namespace mp = boost::multiprecision;
    mp::cpp_int x = mp::pow(mp::cpp_int(2), 1024);
    std::cout << x << "\n";
```
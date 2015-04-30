miniKanren.lua
=================

## Description
[miniKanren](http://minikanren.org/) is a minimalist logic programming language.
This project is an implemention of miniKanren in Lua.


## Usage
Core miniKanren.lua extends Lua with four operations:
`eq()`, `not_eq()`, `all()`, and `conde()`(also `alli()` and `condi()`, where i means interleaves).

`eq()` unifies two terms, which return false when failed to unify, or return a pair called `substitution`.

`not_eq()` and `eq()` works in opposite ways, which return false when the two terms can unified.

There is also two function `run()` and `fresh_vars()`.

`run()` serves as an interface between Lua and miniKanren.lua, and whose value is a list.

`fresh_vars()` introduces a certain number of fresh variables,
which takes an argument to specify the number of fresh variables.


For example:

```lua
a = fresh_vars(1)
run(1, a, conde(
       eq(a, 1),
       eq(a, 2)))
-- {1}
```

The first argument of `run()` specify the number of answer, where `false` means all the answers.

```lua
a = fresh_vars(1)
run(2, a, conde(
       eq(a, 1),
       eq(a, 2)))
-- {1, 2}
```

```lua
a = fresh_vars(1)
run(false, a, conde(
       eq(a, 1),
       eq(a, 2),
       eq(a, 3)))
-- {1, 2, 3}
```

There is a shortcut for `false`:

```lua
a = fresh_vars(1)
run_all(a, conde(
       eq(a, 1),
       eq(a, 2),
       eq(a, 3)))
-- {1, 2, 3}
```

`conde()` and `all()` can be nested within each other.

```lua
a, b = fresh_vars(2)
run(false, {a, b}, conde(
    all(eq(a, 1), eq(b, 1)),
    all(eq(a, 2), eq(b, 2))))
-- { { 1, 1 }, { 2, 2 } }
```

If there is no answer, return an empty table.

```lua
a = fresh_vars(1)
run(false, a, all(
       eq(a, 1),
       eq(a, 2)))
-- {}
```

A string like "\_.0" will be returned when a variable remains unbound. And it represents any value.

```lua
a, b, c = fresh_vars(3)
run(false, a, all(
    eq(a, b),
    eq(1, c)))
-- { "_.0" }
```

not_eq():

```lua
a, b = fresh_vars(2)
run(false, a, all(
    eq(a, b),
    not_eq(b, 2),
    eq(a, 2)))
-- {}
```

```lua
a, b, c = fresh_vars(3)
run(false, a, all(
    eq(a, b),
    eq(b, c),
    not_eq(a, 1),
    not_eq(b, 2),
    not_eq(c, 3)))
-- { "_.0 not eq: 3,2,1" }
```

See [miniKanren: an interactive Tutorial](http://io.livecode.ch/learn/webyrd/webmk) for detail of miniKanren.

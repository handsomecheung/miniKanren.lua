local MK = require("mk")

local run = MK.run
local run_all = MK.run_all
local eq = MK.eq
local all = MK.all
local alli = MK.alli
local condi = MK.condi
local conde = MK.conde
local fresh_vars = MK.fresh_vars
local succeed = MK.succeed
local fail = MK.fail

local list = MK.list

local function is_table(o) return type(o) == "table" end

local function table_eq(t1, t2)
   if not (is_table(t1) and is_table(t2)) then
      return false
   elseif not (getmetatable(t1) == getmetatable(t2)) then
      return false
   else
      for k, v in pairs(t1) do
         if is_table(v) then
            if not table_eq(v, t2[k]) then
               return false
            end
         elseif v ~= t2[k] then
            return false
         end
      end

      for k, v in pairs(t2) do
         if is_table(v) then
            if not table_eq(v, t1[k]) then
               return false
            end
         elseif v ~= t1[k] then
            return false
         end
      end
   end
   return true
end

r, a, b, c, d, e, f, g, a1, q, x = fresh_vars(11)

assert(table_eq(run(20, a,
       conde(
          all(eq(0, 1), eq(a, 1)),
          all(eq(0, 1), eq(a, 2))
       )), {}))

assert(table_eq(run(1, x, eq(x, 5)), {5}))
assert(table_eq(run(1, list(a, b, x), eq(x, 5)), {list("_.1", "_.0", 5)}))

assert(table_eq(run_all(x, all(eq(x, 5))), {5}))
assert(table_eq(run_all(x, all(eq(x, 5), eq(6, 6))), {5}))
assert(table_eq(run_all(x, all(eq(x, 5), eq(x, 6))), {}))

assert(table_eq(run_all(x, conde(eq(x, 5), eq(x, 6))), {5, 6}))
assert(table_eq(run(1, x, conde(eq(x, 5), eq(x, 6))), {5}))
assert(table_eq(run(2, x, conde(eq(x, 5), eq(x, 6))), {5, 6}))
assert(table_eq(run(10, x, conde(eq(x, 5), eq(x, 6))), {5, 6}))

assert(table_eq(run(1, x, conde(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5}))
assert(table_eq(run(2, x, conde(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5, 6}))
assert(table_eq(run(3, x, conde(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5, 6, 7}))

assert(table_eq(run_all(x, conde(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))
assert(table_eq(run(1, x, conde(eq(x, 5), eq(6, 6), eq(7, 7))), {5}))
assert(table_eq(run(2, x, conde(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0"}))
assert(table_eq(run(3, x, conde(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))
assert(table_eq(run(100, x, conde(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))

assert(table_eq(run_all(list(a, b, c), conde(eq(a, 5), eq(b, 6), eq(c, 7))),
                {list(5, "_.1", "_.0"), list("_.1", 6, "_.0"), list("_.1", "_.0", 7)}))

assert(table_eq(run_all(x, conde(eq(x, 5), eq(x, 6), conde(eq(x, 7), eq(x, 8)))),
                {5, 6, 7, 8}))

assert(table_eq(run(1, x, conde(eq(x, 5), eq(x, 6), conde(eq(x, 7), eq(x, 8)))),
                {5}))
assert(table_eq(run(2, x, conde(eq(x, 5), eq(x, 6), conde(eq(x, 7), eq(x, 8)))),
                {5, 6}))
assert(table_eq(run(3, x, conde(eq(x, 5), eq(x, 6), conde(eq(x, 7), eq(x, 8)))),
                {5, 6, 7}))
assert(table_eq(run(4, x, conde(eq(x, 5), eq(x, 6), conde(eq(x, 7), eq(x, 8)))),
                {5, 6, 7, 8}))

assert(table_eq(run_all(x, conde(eq(x, 5), eq(x, 6), all(eq(x, 7), eq(x, 8)))),
                {5, 6}))

assert(table_eq(run_all({x, 5}, conde(eq(x, 5), eq(x, 6), all(eq(x, 7), eq(x, 8)))),
                {{5, 5}, {6, 5}}))

assert(table_eq(run_all(x, conde(eq({x, 1}, {2, 1}), eq({x, x}, {3, 3}))), {2, 3}))

assert(table_eq(run(3, x, conde(
                        eq(x, 2),
                        eq(x, 3),
                        function(s) return eq(x, 4)(s) end
                               )), {2, 3, 4}))

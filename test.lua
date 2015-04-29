inspect = require("inspect")
local function pp(s) print(inspect(s)) end

local MK = require("mk")

local run = MK.run
local run_all = MK.run_all
local eq = MK.eq
local not_eq = MK.not_eq
local all = MK.all
local alli = MK.alli
local condi = MK.condi
local cond = MK.cond
local fresh_vars = MK.fresh_vars
local succeed = MK.succeed
local fail = MK.fail

local list = MK.list

local build_bit= MK.build_bit
local build_num= MK.build_num

local NUM = require("num")
local poso = NUM.poso
local gt1o = NUM.gt1o
local plus_1o = NUM.plus_1o
local pluso = NUM.pluso
local minuso = NUM.minuso
local odd_multo = NUM.odd_multo
local multo = NUM.multo
local lto = NUM.lto
local leo = NUM.leo
local divo = NUM.divo


local E = require("extend")
local mergeo = E.mergeo

local FD = require("fd")
local fd_domain = FD.fd_domain
local fd_all_different = FD.fd_all_different

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

assert(table_eq(run(false, a, (all(eq(a, b), not_eq(b, 2), not_eq(b, 3)))), { "_.0 not eq: 3,2" }))
assert(table_eq(run(false, a, (all(eq(a, b), eq(b, c), not_eq(b, 2), not_eq(b, 3), not_eq(c, 4)))), { "_.0 not eq: 4,3,2" }))
assert(table_eq(run(false, a, (all(eq(a, b), not_eq(b, 2), not_eq(b, 3), not_eq(1, 1)))), {}))

assert(table_eq(run(20, a,
       cond(
          all(eq(0, 1), eq(a, 1)),
          all(eq(0, 1), eq(a, 2))
       )), {}))

assert(table_eq(run(1, x, eq(x, 5)), {5}))
assert(table_eq(run(1, list(a, b, x), eq(x, 5)), {list("_.1", "_.0", 5)}))

assert(table_eq(run_all(x, all(eq(x, 5))), {5}))
assert(table_eq(run_all(x, all(eq(x, 5), eq(6, 6))), {5}))
assert(table_eq(run_all(x, all(eq(x, 5), eq(x, 6))), {}))

assert(table_eq(run_all(x, cond(eq(x, 5), eq(x, 6))), {5, 6}))
assert(table_eq(run(1, x, cond(eq(x, 5), eq(x, 6))), {5}))
assert(table_eq(run(2, x, cond(eq(x, 5), eq(x, 6))), {5, 6}))
assert(table_eq(run(10, x, cond(eq(x, 5), eq(x, 6))), {5, 6}))

assert(table_eq(run(1, x, cond(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5}))
assert(table_eq(run(2, x, cond(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5, 6}))
assert(table_eq(run(3, x, cond(eq(x, 5), eq(x, 6), all(eq(5, 5), eq(x, 7)))), {5, 6, 7}))

assert(table_eq(run_all(x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))
assert(table_eq(run(1, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5}))
assert(table_eq(run(2, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0"}))
assert(table_eq(run(3, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))
assert(table_eq(run(100, x, cond(eq(x, 5), eq(6, 6), eq(7, 7))), {5, "_.0", "_.0"}))

assert(table_eq(run_all(list(a, b, c), cond(eq(a, 5), eq(b, 6), eq(c, 7))),
                {list(5, "_.1", "_.0"), list("_.1", 6, "_.0"), list("_.1", "_.0", 7)}))

assert(table_eq(run_all(x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6, 7, 8}))

assert(table_eq(run(1, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5}))
assert(table_eq(run(2, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6}))
assert(table_eq(run(3, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6, 7}))
assert(table_eq(run(4, x, cond(eq(x, 5), eq(x, 6), cond(eq(x, 7), eq(x, 8)))),
                {5, 6, 7, 8}))

assert(table_eq(run_all(x, cond(eq(x, 5), eq(x, 6), all(eq(x, 7), eq(x, 8)))),
                {5, 6}))

assert(table_eq(run_all({x, 5}, cond(eq(x, 5), eq(x, 6), all(eq(x, 7), eq(x, 8)))),
                {{5, 5}, {6, 5}}))

assert(table_eq(run_all(x, cond(eq({x, 1}, {2, 1}), eq({x, x}, {3, 3}))), {2, 3}))

assert(table_eq(run(3, x, cond(
                        eq(x, 2),
                        eq(x, 3),
                        function(s) return eq(x, 4)(s) end
                               )), {2, 3, 4}))


assert(table_eq(run(false, {a, b, c}, all(eq(a, 2), eq(a, b), not_eq(b, 3))), {{2, 2, "_.0"}}))
assert(table_eq(run(false, {a, b, c}, all(eq(c, 2), eq(a, b), not_eq(b, 3))), { { "_.0 not eq: 3", "_.0 not eq: 3", 2 } }))
assert(table_eq(run(false, {a, b}, all(eq(a, b), not_eq(a, 3))), { { "_.0 not eq: 3", "_.0 not eq: 3" } }))


assert(table_eq(run(false, a, divo(build_bit(9), build_bit(3), a, d)), { { 1, { 1, {} } } }))
assert(table_eq(run(false, d, divo(build_bit(9), build_bit(3), a, d)), { {} }))

assert(table_eq(run(1, a, mergeo({1, {2, {3}}}, {4, {5, {6, {}}}}, a)), { list(1, 2, 3, 4, 5, 6) }))

assert(table_eq(run(1, a, mergeo({1}, {2}, a)), { {1, {2}} }))
assert(table_eq(run(1, a, mergeo({}, {1}, a)), { {1} }))
assert(table_eq(run(1, a, mergeo({1}, {}, a)), { {1, {}} }))

assert(table_eq(run(1, a, fd_all_different({1, {2, {3, {a}}}})), {"_.0"}))
assert(table_eq(run(1, a, fd_all_different({1, {2, {3, {4}}}})), {"_.0"}))
assert(table_eq(run(1, a, fd_all_different({1, {2, {3, {2}}}})), {}))
assert(table_eq(run(1, a, fd_all_different({1, {2, {3, {2, {5}}}}})), {}))

assert(table_eq(run(1, a, fd_all_different(list(1, 2, 3, 4, 5, 6, 7, 8, 9))), {"_.0"}))

assert(table_eq(run(false, a, fd_domain(list(build_bit(2), build_bit(5), build_bit(1), build_bit(9)), build_bit(1), build_bit(9))), {"_.0"}))
assert(table_eq(run(false, a, fd_domain(list(build_bit(2), build_bit(10), build_bit(1), build_bit(9)), build_bit(1), build_bit(9))), {}))

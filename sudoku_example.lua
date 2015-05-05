local MK = require("mk")
local run = MK.run
local run_all = MK.run_all
local eq = MK.eq
local not_eq = MK.not_eq
local all = MK.all
local alli = MK.alli
local cond = MK.cond
local fresh_vars = MK.fresh_vars
local list = MK.list
local car = MK.car
local cdr = MK.cdr

local E = require("extend")
local nullo = E.nullo
local mergeo = E.mergeo
local conso = E.conso

----------------------------------------------------------------------
---------------- different functions ---------------------------------
----------------------------------------------------------------------
local function different_others(x, o)
   local a, d = fresh_vars(2)
   return cond(
      nullo(o),
      all(
         conso(a, d, o),
         not_eq(x, a),
         function(s) return different_others(x, d)(s) end
      ))
end

local function fd_all_different1(c1, a, c2)
   local c, new_c1, new_a, new_c2 = fresh_vars(4)
   return cond(
      nullo(c2),
      all(
         mergeo(c1, c2, c),
         different_others(a, c),
         conso(a, c1, new_c1),
         conso(new_a, new_c2, c2),
         function(s) return fd_all_different1(new_c1, new_a, new_c2)(s) end
      )
   )
end

local function fd_all_different(c)
   local c1, a, c2 = fresh_vars(3)
   return all(
      conso(a, c2, c),
      eq(c1, {}),
      fd_all_different1(c1, a, c2)
   )
end

local function all_different(l)
   local a, d = fresh_vars(2)
   return cond(
      nullo(l),
      all(
         conso(a, d, l),
         fd_all_different(a),
         function(s) return all_different(d)(s) end
      ))
end
----------------------------------------------------------------------

----------------------------------------------------------------------
---------------- domain function -------------------------------------
----------------------------------------------------------------------
local function fd_domain_4(l)
   local a, d = fresh_vars(2)
   return cond(
      nullo(l),
      all(
         conso(a, d, l),
         cond(
            eq(a, 1),
            eq(a, 2),
            eq(a, 3),
            eq(a, 4)),
         function(s) return fd_domain_4(d)(s) end))
end
----------------------------------------------------------------------

local function v()
   return fresh_vars(1)
end

local function list2table(list, t)
   if #list == 0 then
      return t
   else
      table.insert(t, car(list))
      return list2table(cdr(list), t)
   end
end

local function sudoku_4x4(puzzle)
   puzzle = list(unpack(puzzle))

   local s11 , s12, s13, s14,
         s21 , s22, s23, s24,
         s31 , s32, s33, s34,
         s41 , s42, s43, s44,
         row1, row2, row3, row4,
         col1, col2, col3, col4,
         square1, square2, square3, square4 = fresh_vars(28)

   r = run(1, puzzle,
       all(
          eq(puzzle, list(s11, s12, s13, s14,
                          s21, s22, s23, s24,
                          s31, s32, s33, s34,
                          s41, s42, s43, s44)),

          eq(row1, list(s11, s12, s13, s14)),
          eq(row2, list(s21, s22, s23, s24)),
          eq(row3, list(s31, s32, s33, s34)),
          eq(row4, list(s41, s42, s43, s44)),

          eq(col1, list(s11, s21, s31, s41)),
          eq(col2, list(s12, s22, s32, s42)),
          eq(col3, list(s13, s23, s33, s43)),
          eq(col4, list(s14, s24, s34, s44)),

          eq(square1, list(s11, s12, s21, s22)),
          eq(square2, list(s13, s14, s23, s24)),
          eq(square3, list(s31, s32, s41, s42)),
          eq(square4, list(s33, s34, s43, s44)),

          all_different(list(row1, row2, row3, row4,
                             col1, col2, col3, col4,
                             square1, square2, square3, square4)),
          fd_domain_4(puzzle)
       ))

   return #r == 0 and r or list2table(r[1], {})
end

local l = {
   v(), v(), 2  , 3  ,
   v(), 2  , v(), v(),
   2  , v(), v(), v(),
   v(), v(), 1  , 2  ,
}

sudoku_4x4(l)

-- { 1, 4, 2, 3,
--   3, 2, 4, 1,
--   2, 1, 3, 4,
--   4, 3, 1, 2 }

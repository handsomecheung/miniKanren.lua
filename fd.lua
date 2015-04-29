local MK = require("mk")
local eq = MK.eq
local not_eq = MK.not_eq
local all = MK.all
local cond = MK.cond
local fresh_vars = MK.fresh_vars

local E = require("extend")
local nullo = E.nullo
local mergeo = E.mergeo
local conso = E.conso

local NUM = require("num")
local leo = NUM.leo

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
   c, new_c1, new_a, new_c2 = fresh_vars(4)
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
   c1, a, c2 = fresh_vars(3)
   return all(
      conso(a, c2, c),
      eq(c1, {}),
      fd_all_different1(c1, a, c2)
   )
end

local function fd_domain(l, b, u)
   local a, d = fresh_vars(2)
   return cond(
      nullo(l),
      all(
         conso(a, d, l),
         leo(b, a),
         leo(a, u),
         function(s) return fd_domain(d, b, u)(s) end))
end


return {
   fd_domain=fd_domain,
   fd_all_different=fd_all_different,
}

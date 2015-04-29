local MK = require("mk")
local eq = MK.eq
local all = MK.all
local cond = MK.cond
local fresh_vars = MK.fresh_vars

local function nullo(l)
   return eq(l, {})
end

local function conso(a, d, p)
   return eq({a, d}, p)
end

local function pairo(p)
   local a, d = fresh_vars(2)
   return eq({a, d}, p)
end

local function caro(p, a)
   local d = fresh_vars(1)
   return conso(a, d, p)
end

local function cdro(p, d)
   local a = fresh_vars(1)
   return conso(a, d, p)
end

local function counto(p, c)
   local d, cc = fresh_vars(2)
   return cond(
      all(
         nullo(p),
         eq({}, c)),
      all(
         cdro(p, d),
         function(s) return counto(d, cc)(s) end,
         plus_1o(cc, c)
      )
   )
end

local function append_heado(p1, e, p2)
   return conso(e, p1, p2)
end

local function mergeo(p1, p2, p)
   local a, d, pp = fresh_vars(3)
   return cond(
      all(nullo(p1), eq(p2, p)),
      all(
         conso(a, d, p1),
         function(s) return mergeo(d, p2, pp)(s) end,
         append_heado(pp, a, p)
      ))
end

return {
   nullo=nullo,
   conso=conso,
   pairo=pairo,
   caro=caro,
   cdro=cdro,
   counto=counto,
   mergeo=mergeo,
}

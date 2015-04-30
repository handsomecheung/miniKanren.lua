local MK = require("mk")
local eq = MK.eq
local not_eq = MK.not_eq
local all = MK.all
local alli = MK.alli
local condi = MK.condi
local cond = MK.cond
local fresh_vars = MK.fresh_vars

local E = require("extend")
local nullo = E.nullo
local pairo = E.pairo
local cdro = E.cdro

local function full_addero(b, x, y, r, c)
   return cond(
      all(eq(0, b), eq(0, x), eq(0, y), eq(0, r), eq(0, c)),
      all(eq(1, b), eq(0, x), eq(0, y), eq(1, r), eq(0, c)),
      all(eq(0, b), eq(1, x), eq(0, y), eq(1, r), eq(0, c)),
      all(eq(1, b), eq(1, x), eq(0, y), eq(0, r), eq(1, c)),
      all(eq(0, b), eq(0, x), eq(1, y), eq(1, r), eq(0, c)),
      all(eq(1, b), eq(0, x), eq(1, y), eq(0, r), eq(1, c)),
      all(eq(0, b), eq(1, x), eq(1, y), eq(0, r), eq(1, c)),
      all(eq(1, b), eq(1, x), eq(1, y), eq(1, r), eq(1, c)))
end

local function poso(n)
   local a, d = fresh_vars(2)
   return eq({a, d}, n)
end

local function gt1o(n)
   local a, ad, dd = fresh_vars(3)
   return eq({a, {ad, dd}}, n)
end

function gen_addero(d, n, m, r)
   local a, b, c, e, x, y, z = fresh_vars(7)
   return all(
      eq({a, x}, n),
      eq({b, y}, m),
      poso(y),
      eq({c, z}, r),
      poso(z),
      alli(full_addero(d, a, b, c, e), addero(e, x, y, z))
   )
end

function addero(d, n, m, r)
   local a, c = fresh_vars(2)
   return condi(
      all(eq(0, d), eq({}, m), eq(n, r)),
      all(eq(0, d), eq({}, n), eq(m, r), poso(m)),
      all(eq(1, d), eq({}, m), function(s) return addero(0, n, {1}, r)(s) end),
      all(eq(1, d), eq({}, n), poso(m), function(s) return addero(0, {1}, m, r)(s) end),
      all(eq({1}, n), eq({1}, m), eq({a, {c}}, r), full_addero(d, 1, 1, a, c)),
      all(eq({1}, n), function(s) return gen_addero(d, n, m, r)(s) end),
      all(eq({1}, m), gt1o(n), gt1o(r),
          function(s) return addero(d, {1}, n, r)(s) end),
      all(gt1o(n), function(s) return gen_addero(d, n, m, r)(s) end)
   )
end

local function pluso(n, m, k)
   return addero(0, n, m, k)
end

local function plus_1o(n, k)
   return pluso({1}, n, k)
end

local function minuso(n, m, k)
   return pluso(m, k, n)
end

local function bound_multo(q, p, n, m)
   local x, y, z = fresh_vars(3)
   return cond(
      all(nullo(q), pairo(p)),
      all(
         cdro(q, x),
         cdro(p, y),
         condi(
            all(nullo(n),
                cdro(m, z),
                function(s) return bound_multo(x, y, z, {})(s) end),
            all(cdro(n, z),
                function(s) return bound_multo(x, y, z, m)(s) end))))
end

local odd_multo
local function multo(n, m, p)
   local x, y, z = fresh_vars(3)
   return condi(
      all(eq({}, n), eq({}, p)),
      all(poso(n), eq({}, m), eq({}, p)),
      all(eq({1, {}}, n), poso(m), eq(m, p)),
      all(gt1o(n), eq({1, {}}, m), eq(n, p)),
      all(
         eq({0, x}, n), poso(x),
         eq({0, z}, p), poso(z),
         gt1o(m),
         function(s) return multo(x, m, z)(s) end),
      all(
         eq({1, x}, n), poso(x),
         eq({0, y}, m), poso(y),
         function(s) return multo(m, n, p)(s) end),
      all(
         eq({1, x}, n), poso(x),
         eq({1, y}, m), poso(y),
         function(s) return odd_multo(x, n, m, p)(s) end))
end

odd_multo = function(x, n, m, p)
   local q = fresh_vars(1)
   return all(
      bound_multo(q, p, n, m),
      multo(x, m, q),
      pluso({0, q}, m, p))
end


local function eqlo(n, m)
   local a, x, b, y = fresh_vars(4)
   return cond(
      all(eq({}, n), eq({}, m)),
      all(eq({1, {}}, n), eq({1, {}}, m)),
      all(eq({a, x}, n), poso(x),
          eq({b, y}, m), poso(y),
          function(s) return eqlo(x, y)(s) end))
end

local function ltlo(n, m)
   local a, x, b, y = fresh_vars(4)
   return cond(
      all(eq({}, n), poso(m)),
      all(eq({1, {}}, n), gt1o(m)),
      all(eq({a, x}, n), poso(x),
          eq({b, y}, m), poso(y),
          function(s) return ltlo(x, y)(s) end))
end

local function lto(n, m)
   local x = fresh_vars(1)
   return condi(
      ltlo(n, m),
      all(eqlo(n, m),
          poso(x),
          pluso(n, x, m)))
end

local function leo(n, m)
   return condi(
      eq(n, m),
      lto(n, m))
end

local function splito(n, r, l, h)
   local b, n_, a, r_, l_ = fresh_vars(5)
   return condi(
      all(eq({}, n), eq({}, h), eq({}, l)),
      all(eq({0, {b, n_}}, n),
          eq({}, r),
          eq({b, n_}, h),
          eq({}, l)),
      all(eq({1, n_}, n),
          eq({}, r),
          eq(n_, h),
          eq({1, {}}, l)),
      all(eq({0, {b, n_}}, n),
          eq({a, r_}, r),
          eq({}, l),
          function(s) return splito({b, n_}, r_, {}, h)(s) end),
      all(eq({1, n_}, n),
          eq({a, r_}, r),
          eq({1, {}}, l),
          function(s) return splito(n_, r_, {}, h)(s) end),
      all(eq({b, n_}, n),
          eq({a, r_}, r),
          eq({b, l_}, l),
          poso(l_),
          function(s) return splito(n_, r_, l_, h)(s) end))
end

local function divo(n, m, q, r)
   local nh, nl, qh, ql, qlm, qlmr, rr, rh = fresh_vars(8)
   return condi(
      all(eq(r, n), eq({}, q), ltlo(n, m)),
      all(eq({1, {}}, q), eqlo(n, m), pluso(r, m, n),
          lto(r, m)),
      alli(ltlo(m, n),
           lto(r, m),
           poso(q),
           alli(
              splito(n, r, nl, nh),
              splito(q, r, ql, qh)),
           cond(
              all(eq({}, nh),
                  eq({}, qh),
                  minuso(nl, r, qlm),
                  multo(ql, m, qlm)),
              alli(poso(nh),
                   multo(ql, m, qlm),
                   pluso(qlm, r, qlmr),
                   minuso(qlmr, nl, rr),
                   splito(rr, r, {}, rh),
                   function(s) return divo(nh, m, qh, rh)(s) end))))
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

return {
   poso=poso,
   gt1o=gt1o,
   plus_1o=plus_1o,
   pluso=pluso,
   minuso=minuso,
   odd_multo=odd_multo,
   multo=multo,
   lto=lto,
   leo=leo,
   divo=divo,
   counto=counto,
}

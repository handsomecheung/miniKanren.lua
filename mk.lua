local Var = {}
local function var(v) return setmetatable({v}, Var) end
local function is_var(v) return getmetatable(v) == Var end

local function fresh_vars(n)
   n = n or 1
   local vars = {}
   for i=1, n do table.insert(vars, var("fresh_var")) end
   return unpack(vars)
end

local function list_append(l, e)
   local new_list = {}
   for _, v in ipairs(l) do
      table.insert(new_list, v)
   end
   table.insert(new_list, e)
   return new_list
end

local function table_count(t)
   local n = 0
   for _, _ in pairs(t) do n = n + 1 end
   return n
end

local function is_empty(t)
   return table_count(t) == 0
end

local function is_table(o) return type(o) == "table" end
local function is_function(o) return type(o) == "function" end
local function is_pair(p) return is_table(p) and #p > 0 end

local function cons(c, d) return {c, d} end
local function car(p)
   assert(is_pair(p))
   return p[1]
end

local function cdr(p)
   assert(is_pair(p))
   return #p > 1 and p[2] or {}
end

local function pair_count(p)
   if is_empty(p) then
      return 0
   else
      return pair_count(cdr(p)) + 1
   end
end

local function head(t)
   assert(not is_empty(t))
   return t[1]
end

local function tail(t)
   assert(not is_empty(t))
   return {select(2, unpack(t))}
end

local function list(...)
   l = {...}
   if is_empty(l) then
      return {}
   else
      return cons(head(l), list(unpack(tail(l))))
   end
end

local function st_zero() return false end
local function unit(s) return s end

local function succeed(s) return unit(s) end
local function fail(s) return st_zero() end

local Substitution = {}
local function mk_subst(k, v) return setmetatable({k, v}, Substitution) end
local function is_subst(p) return getmetatable(p) == Substitution end
local empty_subst = setmetatable({}, Substitution)

local function ext_subst(k, v, s)
   return setmetatable({{k, v}, s}, Substitution)
end

local Stream = {}
local function mk_stream(subst, f) return setmetatable({subst, f}, Stream) end
local function is_stream(st) return getmetatable(st) == Stream end

local function get_subst(stream)
   assert(is_stream(stream), "not stream")
   assert(#stream == 2, "length not be 2")
   return stream[1]
end

local function get_function(stream)
   assert(is_stream(stream), "not stream")
   assert(#stream == 2, "length not be 2")
   return stream[2]
end

local function assq(k, s)
   if is_empty(s) then return false end
   local ss = car(s)
   if k == car(ss) then
      return cdr(ss)
   else
      return assq(k, cdr(s))
   end
end

local function walk(v, s)
   if is_var(v) then
      local v1 = assq(v, s)
      if is_var(v1) then
         return walk(v1, s)
      elseif v1 == false then
         return v
      else
         return v1
      end
   else
      return v
   end
end

local function walk_all(v, s)
   local v = walk(v, s)
   if is_var(v) then
      return v
   elseif is_pair(v) then
      return cons(walk_all(car(v), s), walk_all(cdr(v), s))
   else
      return v
   end
end

local function unify(k, v, s)
   local k = walk(k, s)
   local v = walk(v, s)
   if k == v then
      return s
   elseif is_var(k) then
      return ext_subst(k, v, s)
   elseif is_var(v) then
      return ext_subst(v, k, s)
   elseif is_pair(v) and is_pair(k) then
      ss = unify(car(v), car(k), s)
      return ss and unify(cdr(v), cdr(k), ss) or false
   elseif is_table(v) and is_empty(v) and is_table(k) and is_empty(k) then
      return s
   else
      return false
   end
end

local function reify_name(n)
   return "_." .. tostring(n)
end

local function reify_s(v, s)
   local v = walk(v, s)
   if is_var(v) then
      return ext_subst(v, reify_name(pair_count(s)), s)
   elseif is_pair(v) then
      return reify_s(car(v), reify_s(cdr(v), s))
   else
      return s
   end
end

local function reify(v)
   return walk_all(v, reify_s(v, empty_subst))
end

local function eq(x, y)
   return function(subst)
      local s = unify(x, y, subst)
      return s and succeed(s) or fail(subst)
   end
end

local function mplus(a_inf, f)
   if not a_inf then
      return f()
   elseif not (is_stream(a_inf) and is_function(get_function(a_inf))) then
      assert(is_subst(a_inf))
      assert(is_function(f))
      return mk_stream(a_inf, f)
   else
      return mk_stream(get_subst(a_inf),
                       function() return mplus(get_function(a_inf)(), f) end)
   end
end

local function bind(a_inf, g)
   if not a_inf then
      return st_zero()
   elseif not (is_stream(a_inf) and is_function(get_function(a_inf))) then
      return g(a_inf)
   else
      return mplus(g(get_subst(a_inf)),
                   function() return bind(get_function(a_inf)(), g) end)
   end
end

local function all(...)
   local g_list = {...}
   if is_empty(g_list) then
      return succeed
   elseif #g_list == 1 then
      return function(s)
         return head(g_list)(s)
      end
   else
      return function(s)
         return bind(head(g_list)(s), all(unpack(tail(g_list))))
      end
   end
end

local function anye(g1, g2)
   return function(s)
      return mplus(g1(s), function() return g2(s) end)
   end
end

local function conde(...)
   local g_list = {...}
   if is_empty(g_list) then
      return fail
   elseif #g_list == 1 then
      return all(head(g_list))
   else
      return anye(all(head(g_list)), conde(unpack(tail(g_list))))
   end
end

local function mplusi(a_inf, f)
   if not a_inf then
      return f()
   elseif not (is_stream(a_inf) and is_function(get_function(a_inf))) then
      assert(is_subst(a_inf))
      assert(is_function(f))
      return mk_stream(a_inf, f)
   else
      return mk_stream(get_subst(a_inf),
                       function() return mplusi(f(), get_function(a_inf)) end)
   end
end

local function bindi(a_inf, g)
   if not a_inf then
      return st_zero()
   elseif not (is_stream(a_inf) and is_function(get_function(a_inf))) then
      return g(a_inf)
   else
      return mplusi(g(get_subst(a_inf)),
                   function() return bindi(get_function(a_inf)(), g) end)
   end
end

local function alli(...)
   local g_list = {...}
   if is_empty(g_list) then
      return succeed
   elseif #g_list == 1 then
      return function(s) return head(g_list)(s) end
   else
      return function(s)
         return bindi(head(g_list)(s), alli(unpack(tail(g_list))))
      end
   end
end

local function anyi(g1, g2)
   return function(s) return mplusi(g1(s), function() return g2(s) end) end
end

local function condi(...)
   local g_list = {...}
   if is_empty(g_list) then
      return fail
   elseif #g_list == 1 then
      return all(head(g_list))
   else
      return anyi(all(head(g_list)), condi(unpack(tail(g_list))))
   end
end

local function run_walk(n, v, s, results)
   if not (n == false or n > 0) then
      return results
   end

   if not s then
      return results
   elseif is_function(s) then
      return run_walk(n, v, s(), results)
   elseif not (is_stream(s) and is_function(get_function(s))) then
      return list_append(results, reify(walk_all(v, s)))
   else
      if n == false then
         return run_walk(n, v, get_function(s),
                         list_append(results, reify(walk_all(v, get_subst(s)))))
      else
         return run_walk(n - 1, v, get_function(s),
                         list_append(results, reify(walk_all(v, get_subst(s)))))
      end
   end
end

local function run(n, v, g)
   local s = g(empty_subst)
   return run_walk(n, v, s, {})
end

local function run_all(v, g)
   return run(false, v, g, {})
end

return {
   run=run,
   run_all=run_all,
   eq=eq,
   all=all,
   alli=alli,
   condi=condi,
   conde=conde,
   fresh_vars=fresh_vars,
   succeed=succeed,
   fail=fail,

   list=list,
}

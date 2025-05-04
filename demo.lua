for k, v in pairs(require("lazy-eval")) do
  _G[k] = v
end

-- "Quicksort" implementation
local function qsort(xs)
  local lst = list(xs)

  if lst ~= nil then
    local pivot = head(lst)
    local rest = tail(lst)

    local lesser = qsort(filter(function(x)
      return x < pivot
    end)(rest))
    local greater = qsort(filter(function(x)
      return x >= pivot
    end)(rest))

    return concat(lesser)(concat({ pivot })(greater))
  end
end

local function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

local shuffled = shuffle(array(take(50)(range(1))))
print("Quicksort\nPre-sorted:")
printList(shuffled)
print("Sorted:")
printList(qsort(shuffled))
print("\n")

-- Sieve of Eratosthenes
local function sieve(xs)
  local lst = list(xs)

  if lst ~= nil then
    return {
      head = lst.head,
      tail = function()
        return sieve(filter(function(x)
          return x % lst.head ~= 0
        end)(tail(lst)))
      end,
    }
  end
end

local primes = sieve(range(2))

print("Sieve of Eratosthenes")
print("primes = sieve(range(2))")
print("take (50) (primes)")
printList(take(50)(primes))
print("takeWhile (ge(29)) (primes)")
printList(takeWhile(ge(29))(primes))
print("\n")

local function water(maxByFar)
  return function(heights)
    local lst = list(heights)
    local hd = head(lst)
    local l = last(lst)

    if not hd or not l then
      return maxByFar
    end

    local h = math.min(hd, l)
    local w = length(lst) - 1
    local max = math.max(w * h, maxByFar)

    if hd > l then
      return water(max)(init(lst))
    else
      return water(max)(tail(lst))
    end
  end
end

print("Container With Most Water problem:\n{ 1, 8, 6, 2, 5, 4, 8, 3, 7 }")
print(water(0)({ 1, 8, 6, 2, 5, 4, 8, 3, 7 }))

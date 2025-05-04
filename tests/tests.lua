package.path = "../?.lua;" .. package.path
for k, v in pairs(require("lazy-eval")) do
  _G[k] = v
end

----- Slicing list -----
-- head & tail --
assert(head({ 1, 2, 3, 4 }) == 1)
assert(head(tail({ 1, 2, 3, 4 })) == 2)
assert(head(tail(tail({ 1, 2, 3, 4 }))) == 3)
assert(head(tail(tail({ 1, 2 }))) == nil)

-- init & last --
assert(last({ 1, 2, 3 }) == 3)
assert(last(init({ 1, 2, 3 })) == 2)

-- nth --
assert(nth(1)({ 1, 2, 3 }) == 1)
assert(nth(3)({ 1, 2, 3 }) == 3)
assert(nth(4)({ 1, 2, 3 }) == nil)
assert(nth(0)({ 1, 2, 3 }) == nil)

-- elem --
assert(elem(1)({ 1, 2, 3 }) == true)
assert(elem(0)({ 1, 2, 3 }) == false)

-- take --
assert(last(take(3)({ 1, 2, 3, 4 })) == 3)
assert(head(take(3)({ 1, 2, 3, 4 })) == 1)
assert(last(take(10)({ 1, 2, 3, 4 })) == 4)

-- takeWhile --
assert(last(takeWhile(ne(3))({ 1, 2, 3, 4, 5 })) == 2)
assert(head(takeWhile(ne(3))({ 1, 2, 3, 4, 5 })) == 1)
assert(last(takeWhile(ne(99))({ 1, 2, 3, 4, 5 })) == 5)

-- drop --
assert(head(drop(3)({ 1, 2, 3, 4, 5 })) == 4)
assert(last(drop(3)({ 1, 2, 3, 4, 5 })) == 5)
assert(head(drop(10)({ 1, 2, 3, 4, 5 })) == nil)

-- dropWhile --
assert(head(dropWhile(ne(3))({ 1, 2, 3, 4, 5 })) == 3)
assert(last(dropWhile(ne(3))({ 1, 2, 3, 4, 5 })) == 5)
assert(head(dropWhile(ne(99))({ 1, 2, 3, 4, 5 })) == nil)

-- remove --
assert(head(remove(3)({ 1, 2, 3, 4, 5 })) == 1)
assert(last(remove(3)({ 1, 2, 3, 4, 5 })) == 5)
assert(any(eq(3))(remove(3)({ 1, 2, 3, 4, 5 })) == false)
assert(last(remove(99)({ 1, 2, 3, 4, 5 })) == 5)

-- split --
assert(head(split(le(3))({ 1, 2, 3, 4, 5 })(1)) == 1)
assert(last(split(le(3))({ 1, 2, 3, 4, 5 })(1)) == 2)
assert(head(split(le(3))({ 1, 2, 3, 4, 5 })(2)) == 3)
assert(last(split(le(3))({ 1, 2, 3, 4, 5 })(2)) == 5)

assert(head(split(le(99))({ 1, 2, 3, 4, 5 })(1)) == 1)
assert(last(split(le(99))({ 1, 2, 3, 4, 5 })(1)) == 5)
assert(head(split(le(99))({ 1, 2, 3, 4, 5 })(2)) == nil)
assert(last(split(le(99))({ 1, 2, 3, 4, 5 })(2)) == nil)

assert(head(split(le(0))({ 1, 2, 3, 4, 5 })(1)) == nil)
assert(last(split(le(0))({ 1, 2, 3, 4, 5 })(1)) == nil)
assert(head(split(le(0))({ 1, 2, 3, 4, 5 })(2)) == 1)
assert(last(split(le(0))({ 1, 2, 3, 4, 5 })(2)) == 5)

-- splitAt --
assert(head(splitAt(3)({ 1, 2, 3, 4, 5 })(1)) == 1)
assert(last(splitAt(3)({ 1, 2, 3, 4, 5 })(1)) == 3)
assert(head(splitAt(3)({ 1, 2, 3, 4, 5 })(2)) == 4)
assert(last(splitAt(3)({ 1, 2, 3, 4, 5 })(2)) == 5)

assert(head(splitAt(99)({ 1, 2, 3, 4, 5 })(1)) == 1)
assert(last(splitAt(99)({ 1, 2, 3, 4, 5 })(1)) == 5)
assert(head(splitAt(99)({ 1, 2, 3, 4, 5 })(2)) == nil)
assert(last(splitAt(99)({ 1, 2, 3, 4, 5 })(2)) == nil)

assert(head(splitAt(0)({ 1, 2, 3, 4, 5 })(1)) == nil)
assert(last(splitAt(0)({ 1, 2, 3, 4, 5 })(1)) == nil)
assert(head(splitAt(0)({ 1, 2, 3, 4, 5 })(2)) == 1)
assert(last(splitAt(0)({ 1, 2, 3, 4, 5 })(2)) == 5)

-- splitStr --
assert(head(splitStr("hello world")(".")) == "h")
assert(last(splitStr("hello world")(".")) == "d")
assert(head(splitStr("hello;world;")("([^;]*);")) == "hello")
assert(last(splitStr("hello;world;")("([^;]*);")) == "world")

----- Generators ----
-- range --
assert(head(take(100)(range(1))) == 1)
assert(last(take(100)(range(1))) == 100)
assert(nth(20100)(range(1)) == 20100)

-- rangeDesc --
assert(head(take(100)(range(-1))) == -1)

-- repeatValue --
assert(head(take(10)(repeatValue(5))) == 5)
assert(last(take(10)(repeatValue(5))) == 5)

-- cycle --
assert(head(take(6)(cycle({ 1, 2, 3 }))) == 1)
assert(last(take(6)(cycle({ 1, 2, 3 }))) == 3)

-- iterate --
assert(head(take(10)(iterate(mul(2))(1))) == 1)
assert(last(take(10)(iterate(mul(2))(1))) == 512)

----- Filters -----
assert(dump(filter(even)(take(10)(range(1)))) == "[2, 4, 6, 8, 10]")

----- Mapping -----
assert(dump(map(mul(2))(take(10)(range(1)))) == "[2, 4, 6, 8, 10, 12, 14, 16, 18, 20]")

----- Folding -----
-- foldr & foldl
assert(foldr(add)(0)({ 1, 2, 3, 4 }) == 10)
assert(foldl(add)(0)({ 1, 2, 3, 4 }) == 10)

-- sum --
assert(sum({ 1, 2, 3, 4 }) == 10)

-- product --
assert(product({ 1, 2, 3, 4 }) == 24)

-- all --
assert(all(eq(1))({ 1, 1, 1, 1, 1 }) == true)
assert(all(eq(1))({ 1, 1, 1, 1, 2 }) == false)

-- any --
assert(any(eq(2))({ 1, 1, 1, 1, 2 }) == true)
assert(any(eq(2))({ 1, 1, 1, 1, 1 }) == false)

----- Function composition -----
local add2 = function(a)
  return a + 2
end

local mul3 = function(a)
  return a * 3
end

-- pipe --
assert(pipe({ add2, mul3 })(5) == 21)

-- comp --
assert(comp({ add2, mul3 })(5) == 17)

----- Modifying -----
-- concat --
assert(head(concat({ 1, 2, 3, 4 })({ 5, 6 })) == 1)
assert(last(concat({ 1, 2, 3, 4 })({ 5, 6 })) == 6)

-- concatStr --
local splittedStr = list("blah")
assert(concatStr(splittedStr)() == "blah")
assert(concatStr(splittedStr)("") == "blah")
assert(concatStr(splittedStr)(",") == "b,l,a,h")

-- reverse --
assert(head(reverse({ 1, 2, 3, 4, 5 })) == 5)
assert(last(reverse({ 1, 2, 3, 4, 5 })) == 1)

----- Zipping -----
local first = list({ 1, 2, 3 })
local second = list({ 4, 5, 6 })
assert(dump(unzip(1)(zip(first)(second))) == dump(first))
assert(dump(unzip(2)(zip(first)(second))) == dump(second))

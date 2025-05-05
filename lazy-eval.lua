local p = {}

----- Helper functions -----
local function removeFirstElement(arr)
  local output = {}
  for i, v in ipairs(arr) do
    if i ~= 1 then
      output[#output + 1] = v
    end
  end
  return output
end

local function integerCheck(num)
  if type(num) ~= "number" or num ~= math.floor(num) then
    return error("`num` must be a whole integer.")
  end
end

local function posIntegerCheck(num)
  integerCheck(num)
  if num < 0 then
    return error("`num` must be a whole positive integer.")
  end
end

local function tupleIndexCheck(num)
  posIntegerCheck(num)
  if not (num == 1 or num == 2) then
    return error("tuple index can be only 1 or 2.")
  end
end

local function functionCheck(fn)
  if type(fn) ~= "function" then
    return error("`fn` must be a function.")
  end
end

----- Basic functions ---
function p.list(xs)
  if xs == nil then
    return nil
  end
  if type(xs) == "string" then
    return p.splitStr(xs)(".")
  end
  if type(xs) ~= "table" then
    return error("`xs` must be a table.")
  end

  if xs.head and xs.tail then
    functionCheck(xs.tail)
    return xs
  end

  if #xs == 0 then
    return nil
  else
    return {
      head = xs[1],
      tail = function()
        return p.list(removeFirstElement(xs))
      end,
    }
  end
end

function p.dump(xs)
  local list = p.list(xs)
  local head = nil
  if list == nil then
    return nil
  end

  head = list.head

  local out = {}

  while head do
    if type(head) == "string" then
      out[#out + 1] = '"' .. head .. '"'
    elseif type(head) == "table" then -- tuple
      out[#out + 1] = "(" .. p.dump(head) .. ")"
    else
      out[#out + 1] = tostring(head)
    end
    list = list.tail()
    head = list and list.head or nil
  end

  return "[" .. table.concat(out, ", ") .. "]"
end

function p.printList(xs)
  print(p.dump(xs))
end

function p.createList(xs)
  return function(head_ret)
    return function(tail_ret)
      if xs ~= nil then
        return {
          head = head_ret,
          tail = tail_ret,
        }
      end
    end
  end
end

function p.array(list)
  local xs = {}
  local head = nil
  if list == nil then
    return nil
  end
  if type(list) ~= "table" then
    return error("`list` must be a table.")
  end
  if not list.head and not list.tail then
    return list
  end

  head = list.head

  while head do
    xs[#xs + 1] = head
    list = list.tail()
    head = list and list.head or nil
  end

  return xs
end

----- Slicing list -----
function p.head(xs)
  local list = p.list(xs)

  if list ~= nil then
    return list.head
  end
end

function p.tail(xs)
  local list = p.list(xs)

  if list ~= nil then
    return list.tail()
  end
end

function p.init(xs)
  local list = p.list(xs)

  if list ~= nil and p.tail(list) then
    return {
      head = list.head,
      tail = function()
        return p.init(p.tail(list))
      end,
    }
  end
end

function p.last(xs)
  local list = p.list(xs)

  if list ~= nil then
    if list.tail() == nil then
      return list.head
    else
      return p.last(p.tail(list))
    end
  end
end

function p.nth(index)
  integerCheck(index)
  return function(xs)
    if index <= 0 then
      return nil
    end
    local list = p.list(xs)

    if list ~= nil then
      if index == 1 then
        return list.head
      else
        return p.nth(index - 1)(p.tail(list))
      end
    end
  end
end

function p.elem(val)
  return function(xs)
    local list = p.list(xs)

    if list == nil then
      return false
    end

    if list.head == val then
      return true
    else
      return p.elem(val)(p.tail(xs))
    end
  end
end

function p.take(num)
  posIntegerCheck(num)
  return function(xs)
    if num <= 0 or xs == nil then
      return nil
    end
    local list = p.list(xs)

    if list ~= nil then
      return {
        head = list.head,
        tail = function()
          return p.take(num - 1)(p.tail(list))
        end,
      }
    end
  end
end

function p.takeWhile(fn)
  functionCheck(fn)
  return function(xs)
    local list = p.list(xs)

    if list ~= nil then
      if not fn(list.head) then
        return nil
      end
      return {
        head = list.head,
        tail = function()
          return p.takeWhile(fn)(p.tail(list))
        end,
      }
    end
  end
end

function p.drop(num)
  posIntegerCheck(num)
  return function(xs)
    local list = p.list(xs)

    if list ~= nil then
      if num > 0 then
        return p.drop(num - 1)(p.tail(list))
      else
        return {
          head = list.head,
          tail = list.tail,
        }
      end
    end
  end
end

function p.dropWhile(fn)
  functionCheck(fn)
  return function(xs)
    local list = p.list(xs)

    if list ~= nil then
      if fn(list.head) then
        return p.dropWhile(fn)(p.tail(list))
      else
        return {
          head = list.head,
          tail = list.tail,
        }
      end
    end
  end
end

function p.remove(num)
  posIntegerCheck(num)
  return function(xs)
    local list = p.list(xs)

    if list ~= nil then
      if num == 0 then
        return list
      elseif num == 1 then
        return p.tail(list)
      else
        return {
          head = list.head,
          tail = function()
            return p.remove(num - 1)(p.tail(list))
          end,
        }
      end
    end
  end
end

function p.split(fn)
  functionCheck(fn)
  return function(xs)
    local list = p.list(xs)
    return function(num)
      tupleIndexCheck(num)

      if list ~= nil then
        if num == 1 then
          if not fn(list.head) then
            return {
              head = list.head,
              tail = function()
                return p.split(fn)(p.tail(list))(1)
              end,
            }
          else
            return nil
          end
        else
          if fn(list.head) then
            return list
          else
            return p.split(fn)(p.tail(list))(2)
          end
        end
      end
    end
  end
end

function p.splitAt(num)
  posIntegerCheck(num)
  return function(xs)
    local list = p.list(xs)

    return function(index)
      tupleIndexCheck(index)
      if list ~= nil then
        if index == 1 then
          if num ~= 0 then
            return {
              head = list.head,
              tail = function()
                return p.splitAt(num - 1)(p.tail(list))(1)
              end,
            }
          else
            return nil
          end
        else
          if num == 0 then
            return list
          elseif num == 1 then
            return p.tail(list)
          else
            return p.splitAt(num - 1)(p.tail(list))(2)
          end
        end
      end
    end
  end
end

function p.splitStr(str)
  return function(sep)
    local arr = {}
    for i in string.gmatch(str, sep) do
      arr[#arr + 1] = i
    end
    return p.list(arr)
  end
end

----- Generators -----
function p.range(begin)
  integerCheck(begin)
  return {
    head = begin,
    tail = function()
      return p.range(begin + 1)
    end,
  }
end

function p.rangeDesc(begin)
  integerCheck(begin)
  return {
    head = begin,
    tail = function()
      return p.rangeDesc(begin - 1)
    end,
  }
end

function p.repeatValue(val)
  return {
    head = val,
    tail = function()
      return p.repeatValue(val)
    end,
  }
end

function p.cycle(xs)
  local list = p.list(xs)

  if list ~= nil then
    return {
      head = list.head,
      tail = function()
        return p.cycle(p.concat(p.tail(list))({ list.head }))
      end,
    }
  end
end

function p.iterate(fn)
  functionCheck(fn)
  return function(acc)
    return {
      head = acc,
      tail = function()
        return p.iterate(fn)(fn(acc))
      end,
    }
  end
end

----- Filters -----
function p.filter(fn)
  functionCheck(fn)
  return function(xs)
    local list = p.list(xs)

    if list ~= nil then
      if fn(list.head) then
        return {
          head = list.head,
          tail = function()
            return p.filter(fn)(p.tail(list))
          end,
        }
      else
        return p.filter(fn)(p.tail(list))
      end
    end
  end
end

----- Mapping -----
function p.map(fn)
  functionCheck(fn)
  return function(xs)
    local list = p.list(xs)

    if list ~= nil then
      return {
        head = fn(list.head),
        tail = function()
          return p.map(fn)(p.tail(list))
        end,
      }
    end
  end
end

----- Folding -----
function p.foldr(fn)
  functionCheck(fn)
  return function(init)
    return function(xs)
      local list = p.list(xs)

      if list == nil then
        return init
      end

      return fn(list.head)(p.foldr(fn)(init)(p.tail(list)))
    end
  end
end

function p.foldl(fn)
  functionCheck(fn)
  return function(init)
    return function(xs)
      local list = p.list(xs)

      if list == nil then
        return init
      end

      return p.foldl(fn)(fn(init)(list.head))(p.tail(list))
    end
  end
end

function p.sum(xs)
  return p.foldr(function(a)
    return function(b)
      return a + b
    end
  end)(0)(xs)
end

function p.product(xs)
  return p.foldr(function(a)
    return function(b)
      return a * b
    end
  end)(1)(xs)
end

function p.all(fn)
  functionCheck(fn)
  return function(xs)
    local list = p.list(xs)

    if list == nil then
      return true
    end

    if not fn(list.head) then
      return false
    else
      return p.all(fn)(p.tail(list))
    end
  end
end

function p.any(fn)
  functionCheck(fn)
  return function(xs)
    local list = p.list(xs)

    if list == nil then
      return false
    end

    if fn(list.head) then
      return true
    else
      return p.any(fn)(p.tail(list))
    end
  end
end

----- Function composition -----
function p.pipe(xs)
  return function(val)
    return p.foldl(function(init)
      return function(fn)
        return fn(init)
      end
    end)(val)(xs)
  end
end

function p.comp(xs)
  return function(val)
    return p.foldr(function(fn)
      return function(init)
        return fn(init)
      end
    end)(val)(xs)
  end
end

----- Modifying -----
function p.concat(xs1)
  return function(xs2)
    local list1 = p.list(xs1)
    local list2 = p.list(xs2)

    if list1 ~= nil then
      return {
        head = list1.head,
        tail = function()
          return p.concat(p.tail(list1))(list2)
        end,
      }
    else
      return list2
    end
  end
end

function p.concatStr(xs)
  return function(sep)
    local arr = p.array(xs)
    if arr ~= nil then
      return table.concat(arr, sep)
    end
  end
end

function p.reverse(xs)
  local arr = p.array(xs)

  if arr ~= nil then
    table.sort(arr, function(a, b)
      return b < a
    end)
  end

  return p.list(arr)
end

----- Zipping -----
function p.zip(xs1)
  local list1 = p.list(xs1)
  return function(xs2)
    local list2 = p.list(xs2)

    if list1 ~= nil and list2 ~= nil then
      return {
        head = { list1.head, list2.head },
        tail = function()
          return p.zip(p.tail(xs1))(p.tail(xs2))
        end,
      }
    end
  end
end

function p.zipWith(fn)
  functionCheck(fn)
  return function(xs1)
    local list1 = p.list(xs1)
    return function(xs2)
      local list2 = p.list(xs2)

      if list1 ~= nil and list2 ~= nil then
        return {
          head = fn(list1.head)(list2.head),
          tail = function()
            return p.zipWith(fn)(p.tail(xs1))(p.tail(xs2))
          end,
        }
      end
    end
  end
end

function p.unzip(num)
  tupleIndexCheck(num)
  return function(xs)
    local list = p.list(xs)

    if list ~= nil then
      return {
        head = list.head[num],
        tail = function()
          return p.unzip(num)(p.tail(xs))
        end,
      }
    end
  end
end

------ Operators ------
p.lt = function(a)
  return function(b)
    return a < b
  end
end
p.le = function(a)
  return function(b)
    return a <= b
  end
end
p.eq = function(a)
  return function(b)
    return a == b
  end
end
p.ne = function(a)
  return function(b)
    return a ~= b
  end
end
p.ge = function(a)
  return function(b)
    return a >= b
  end
end
p.gt = function(a)
  return function(b)
    return a > b
  end
end

p.add = function(a)
  return function(b)
    return a + b
  end
end
p.div = function(a)
  return function(b)
    return a / b
  end
end
p.mod = function(a)
  return function(b)
    return a % b
  end
end
p.mul = function(a)
  return function(b)
    return a * b
  end
end
p.un = function(a)
  return -a
end
p.pow = function(a)
  return function(b)
    return a ^ b
  end
end
p.sub = function(a)
  return function(b)
    return a - b
  end
end

p.strconcat = function(a)
  return function(b)
    return a .. b
  end
end
p.arrlen = function(a)
  return #a
end

p.length = function(xs)
  local list = p.list(xs)

  if list == nil then
    return 0
  end

  return 1 + p.length(p.tail(xs))
end

p.land = function(a)
  return function(b)
    return a and b
  end
end
p.lor = function(a)
  return function(b)
    return a or b
  end
end
p.lnot = function(a)
  return not a
end
p.ltrue = function(a)
  return not not a
end

p.even = function(a)
  return a % 2 == 0
end

p.odd = function(a)
  return a % 2 ~= 0
end

return p

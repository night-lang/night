-- Night
-- src/lexer/constants.lua
-- Constants for lexer.lua

local type, pairs = type, pairs
local Const = {
  identifier = {},
  digits     = {},
  quote      = {},
}

-- Whites
Const.space     = {" ", "\t"}
Const.linebreak = {"\r", "\n"}
Const.white    = {Const.space, Const.linebreak}

-- Identifiers
Const.identifier.invalidStart = "+-*/%&|\"'()[]{}^:.!0123456789"
Const.identifier.invalid      = "+-*/%&|\"'()[]{}^:."

-- Digits
Const.digits.dec = "0123456789"
Const.digits.bin = "01"
Const.digits.hex = "ABCDEF"
Const.digits.oct = "01234567"
Const.digits.zr  = "0"
Const.digits.mod = "dbxc"
Const.digits.all = "0123456789ABCDEF"
-- Quotes
Const.quote.single = "'"
Const.quote.double = '"'
Const.quote.symbol = ":"

-- Escapes
Const.slash     = "/"
Const.backslash = "\\"

-- Comparing function
Const.eq = function()end
function Const.eq(a,b)
  if type(b) == "string" then
    return b:match(a)
  elseif type(b) == "table" then
    for _,e in pairs(b) do
      return Const.eq(a,e)
    end
  end
end

return Const
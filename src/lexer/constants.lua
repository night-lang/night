--[[
Night | lexer/constants.lua
..... | Constants for the lexer.
..... | By daelvn (daelvn@gmail.com)
..... | MIT Licensed
]]--

-- Linter
local ipairs = ipairs
local string = string

-- Load LPeg
local lpeg = require "lpeg"

-- Util
local function urange(us,ue)
  local r  = lpeg.P("")
  for i=us,ue do
    r = r + lpeg.P(string.char(i))
  end
  return r
end

-- Create constants
return {
  white  = lpeg.S("\r\n\t")^0,
  space  = lpeg.S(" ")^0,
  wspace = lpeg.S(" \r\n\t")^0,
  
  identifier_char_start = 1 - lpeg.S("+-*/%&|\"'()[]{}^:.!"),
  identifier_char       = 1 - lpeg.S("+-*/%&|\"'()[]{}^:."),
  
  digit    = lpeg.R("09"),
  hexdigit = lpeg.R("09", "AF", "af"),
  octdigit = lpeg.R("07"),
  bindigit = lpeg.R("01"),
  
  squote = lpeg.P("'"),
  dquote = lpeg.P("\""),
  
  any    = 1 - lpeg.S("\r\n\t")^0,
  wany   = lpeg.P(1),
  
  escape = lpeg.P("\\") * lpeg.P(1),
  
  slash  = lpeg.P("/"),
  bslash = lpeg.P("\\"),
  
  instring = lpeg.P(1) + (lpeg.P("\\") * lpeg.P(1)),
  inchar   = lpeg.P(1) + (lpeg.P("\\") * lpeg.P(1)),
}
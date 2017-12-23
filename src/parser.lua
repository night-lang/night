--[[
Night | parser.lua
..... | Takes the source code, creates an AST.
..... | By daelvn (daelvn@gmail.com)
..... | MIT Licensed
]]--

-- Use LPeg
local lpeg = require "lpeg"
local P    = lpeg.P
local S    = lpeg.S
local R    = lpeg.R
local V    = lpeg.V

-- Linter
local type, ipairs, setmetatable, error = type, ipairs, setmetatable, error
local string, table                     = string, table

-- Lexer parts
local C = require "lexer.constants"
local O = require "lexer.scope"

-- Scope functions (AST Creating)
local function Sc (parent)
  local Scope = {
    Parent    = parent,
    Variables = {},
    Children  = {}
  }
  table.insert(parent.Children, Scope)
  return Scope
end

-- Node functions (AST Creating)
local function Eb (p) -- Boolean expr
  return p / function (value)
    return {
      Kind  = "expr",
      Type  = "Boolean",
      Value = value
    }
  end
end

local function Eni (p, value, sci) -- Integer expr
  return {
    Kind  = "expr",
    Type  = "Integer",
    Value = value,
    NSci  = sci
  }
end

local function Enf (p, value, sci) -- Float expr
  return {
    Kind  = "expr",
    Type  = "Float",
    Value = value,
    NSci  = sci
  }
end

local function Ens (p, value) -- Scientific expr
  local resolve_be = "0" .. value:match("[+-]*%d*%.*%d+[eE]"):match("[+-]%d*%.*%d+"):gsub("+", "")
  local resolve_ae = value:match("[eE][+-]*%d"):match("[+-]*%d"):gsub("+", "")
  local sign       = resolve_ae:match(".")
  if not sign:match("[+-]") then sign = "+" end
  local resolve    = resolve_be.tonumber() * (10 ^ resolve_ae.tonumber())
  if (resolve % 1) ~= 0 then
    return Enf(p, resolve, true)
  else
    return Eni(p, resolve, true)
  end
end

local function En (p) -- Number expr
  return p / function (value)
    if value:match("eE") then return Ens(p, value) elseif
       value:match("%.") then return Enf(p, value) else
       return Eni(p, value) end
  end
end

local function Esc (p, value) -- Char expr
  return {
    Kind  = "expr",
    Type  = "Char",
    Value = value
  }
end

local function Ess (p, value) -- Symbol expr
  return {
    Kind  = "expr",
    Type  = "Symbol",
    Value = value
  }
end

local function Est (p, value) -- String literal expr
  return {
    Kind  = "expr",
    Type  = "String",
    Value = value
  }
end

local function Es (p) -- String expr
  return p / function (value)
    if value:match("^:") then return Ess (p, value) elseif
       value:match("^'") then return Esc (p, value) elseif
       value:match("^\"") then return Est (p, value) end
  end
end

local function Ef (p) -- Function declaration expression
  -- id? ( args? ) : block 
  return p / function (id, args, block)
    return {
      Kind   = "expr",
      Type   = "Function",
      Value  = {id, args, block},
      FId    = id,
      -- TODO Define Ga and Gb id:1 gh:5
      FArgl  = Ga(args), -- Group_args
      FBlock = Gb(block) -- Group_blocks
    }
  end
end

local function Ec (p) -- Class declaration expression
  -- id? ( args? ) :: block 
  return p / function (id, args, block)
    return {
      Kind   = "expr",
      Type   = "Class",
      Value  = {id, args, block},
      CId    = id,
      -- TODO Define Ga and Gb id:0 gh:4
      CArgl  = Ga(args), -- Group_args
      CBlock = Gb(block) -- Group_blocks
    }
  end
end

local function Et (p) -- Table declaration
  -- [ key* expr ,* ]
end



-- Define lexical elements
-- Comments
local Lcomment_line  = P "//" * (1 - O.white)^0
local Lcomment_block = P "/*" * (1 - P "*/")^0 * P "*/"
local Lcomment       = O.wspace * C(Lcomment_line + Lcomment_block)

-- Numbers
local Lnumber_integer    = (S "+-"^-1) * ((O.digit + O.hexdigit + O.octdigit + O.bindigit)^1)
local Lnumber_fractional = P "." * (O.digit + O.hexdigit + O.octdigit + O.bindigit)^1
local Lnumber_decimal    = (Lnumber_integer * (Lnumber_fractional^-1)) * (S("+-") * Lnumber_fractional)
local Lnumber_scientific = Lnumber_decimal * (S "Ee")  * Lnumber_integer
local Lnumber            = O.wspace * C(Lnumber_decimal + Lnumber_scientific)

-- Operators
local Loperators_arithmetic_simple  = P "+"^-1 + P "-"^-1 + P "*"^-1 + P "/"^-1 + P "%"^-1 + P "**"
local Loperators_arithmetic_complex = P "++" + P "--" + P ".."
local Loperators_boolean_simple     = P "!"^-1 + P ">"^-1 + P "<"^-1
local Loperators_boolean_complex    = P "==" + P "!=" + P "<=" + P ">="
local Loperators_logical            = P "&&" + P "||"
local Loperators_bitwise            = P "&" + P "|" + P "^" + P "<<" + P ">>"
local Loperators_assignment         = O.wspace * C((Loperators_arithmetic_simple +
                                       Loperators_boolean_simple +
                                       Loperatprs_boolean_complex +
                                       Loperators_logical +
                                       Loperators_bitwise +
                                       (1 - P "")) * P "=")
local Loperators_declaration        = P ":"^-2
local Loperators_class              = P "<+" + P "<-"
local Loperators_composition        = P "<|"
local Loperators_access             = P "."^-1
local Loperator = O.wspace * C(Loperators_arithmetic_simple + Loperators_arithmetic_complex + Loperators_boolean_simple +
                  Loperators_boolean_complex + Loperators_logical + Loperators_bitwise + Loperators_assignment +
                  Loperators_declaration + Loperators_class + Loperators_composition + Loperators_access)

-- Blocks
local Lblock_arguments = O.wspace * C(P "(" * (1 - P ")")^0 * P ")")
local Lblock_code      = O.wspace * C(P "{" * (1 - P "}")^0 * P "}")

-- Strings
local Lstring_complete = O.dquote * O.instring^0 * O.dquote
local Lstring_char     = O.squote * O.inchar^0 * O.squote
local Lstring_symbol   = P ":" * O.identifier_char_start^-1 * O.identifier_char^0
local Lstring          = O.wspace * C(Lstring_complete + Lstring_char + Lstring_symbol)

-- Total identifier
local Lidentifier = O.wspace * C(O.identifier_char_start^-1 * O.identifier_char^0)

-- Syntax elements

-- Define grammar
local G = P{
  "main",
  lhs  = Lidentifier * Lidentifier,
  id   = Lidentifier
}




--[[
Night | parser.lua
..... | Takes the source code, creates an AST.
..... | By daelvn (daelvn@gmail.com)
..... | MIT Licensed
]]--

-- Use LPeg
local lpeg = require "lpeg"
local P    = lpeg.P
local T    = lpeg.S
local R    = lpeg.R
local V    = lpeg.V

-- Linter
local type, ipairs, setmetatable, error = type, ipairs, setmetatable, error
local string                            = string

-- Lexer parts
local C = require "lexer.constants"
local S = require "lexer.scope"

-- Node functions (AST Creating)
-- Create block node
local function Nb (patt, Type, Scope, Anon)
  return patt / function()
  return {
    AstType   = "Block",
    LexType   = Type,
    Scope     = Scope,
    
    Anonymous = Anon,
    Name      = N,
  }
  end
end
-- Create function node
local function Nf (patt) return Nb (patt, "Function") end
-- Create class node
local function Nc (patt) return Nb (patt, "Class") end


-- Define grammar
local G = P{
  "shebang",
  shebang = P "#!" * (1 - C.white)^0,
  -- Comments
  comment_line  = P "//" * (1 - C.white)^0,
  comment_block = P "/*" * (1 - P "*/")^0 * P "*/",
  
  comment       = V "comment_line" + V "comment_block",
  
  -- Digits
  number_digit = R "09",
  number_integer    = (S "+-"^-1) * (V "number_digit"^1),
  number_fractional = P "." * V "number_digit"^1,
  number_decimal    = (V "number_integer" * (V "number_fractional"^-1)) * (S("+-") * V "number_fractional"),
  number_scientific = V "number_decimal" * S("Ee") * V "number_integer",
  
  number     = V "number_decimal" + V "number_scientific",
}




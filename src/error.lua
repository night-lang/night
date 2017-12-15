-- Night
-- src/error.lua
-- Error emitting

-- Setup namespace
local _error = error
local error  = {}

-- Linter
local print, tostring = print, tostring
local string          = string

-- Load color library
local color = require "color"

function error.getLine (stream, line)
  
end



function error.solve (line, lnc, chc, chplnc, expected)
  print ( color.fg.RED .. "! Oops, something went wrong!")
  print ("! Line "..tostring(lnc)..", Char "..tostring(chc)..", Char in line "..tostring(chplnc))
  print ("! "..line)
  print ("! "..string.rep(" ", chplnc-1)..string.rep("^" ))
end

-- Return namespace
return error
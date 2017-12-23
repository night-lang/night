-- Night-rw
-- lexer.lua
-- Code -> Token Stream

-- Linter --
local print, pairs = print, pairs

-- Libraries --
-- This requires the path to contain "./lib/?/main.lua;./lib/?/?.lua;/lib/?.lua" (at least)
local color = require "color"

-- Flags --
local _debug_ = true

-- Helper functions --
local function D (e)
  e = e:gsub("Night va02", color.fg.RED.."%1")
  if _debug_ then print(e) end
end

-- Start output --
D ("Night va02")



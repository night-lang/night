-- Night
-- src/lexer.lua
-- Code -> Token stream

local print, pairs = print, pairs

-- Load utils
local C  = dofile "lexer/constants.lua"
local E  = C.eq
local _d = true

-- Load libraries
-- TODO libinspect should be provided automatically with the package manager, not Night itself.
-- TODO fix require for ComputerCraft.
-- This requires the path to contain "./lib/?/main.lua;./lib/?/?.lua;/lib/?.lua"
local inspect = require "libinspect"
local color   = require "color"
local error   = require "error"

local D  = function(s)
  s = s:gsub(":",       color.fg.BLUE..color.bold ..":"..     color.reset)
  s = s:gsub("%-+",     color.fg.white..color.bold.."%1"..    color.reset)
  s = s:gsub("C%d",     color.fg.PINK             .."%1"..    color.reset)
  s = s:gsub("CA",      color.fg.PINK             .."%1"..    color.reset)
  s = s:gsub("=",       color.fg.pink..color.bold .."%1"..    color.reset)
  s = s:gsub(">.+",     color.fg.CYAN             .."%1"..    color.reset)
  s = s:gsub("INUSE%?", color.fg.YELLOW           .."%1"..    color.reset)
  s = s:gsub("/",       color.fg.cyan             .."/"..     color.reset)
  s = s:gsub("nightl",  color.fg.RED              .."nightl"..color.reset)
  if _d then print(s) end
end
D ": nightl"

-- Define parameters
D ": Defining parameters"
local A = {...}
local I = A[1]

-- Define holders
D ": Defining holders"
local CA         = ""
local C0         = I:sub(1,1)
local C1         = I:sub(2,2)
local htoken     = ""
local htype      = ""
local hstream    = {}
local _chc, _lnc = 1,1
local _chplnc    = 1
-- Define INUSE
local INUSE = {
  whitespace = false,
  digit      = false,
}
local INUSE_current = ""
local function INUSE_turnoff_but(key)
  for k,v in pairs(INUSE) do
    if k ~= key then v = false else v = true; INUSE_current = k end
  end
end
-- Define VAL
local VAL = {}
-- Lexing loop
D ": Defining lexer loop"
local CI    = function() CA = C0; C0 = I:sub(_chc,_chc); C1 = I:sub(_chc+1,_chc+1) end
while C0 ~= "" do -- If !EOF
  D "-----------"
  D ("= CA "..CA)
  D ("= C0 "..C0)
  D ("= C1 "..C1)
  D ("INUSE? "..INUSE_current)
  D ("= htoken "..htoken)
  -- Whitespace
  if E(C0, C.white) then
    INUSE_turnoff_but("whitespace")
    D " > Whitespace"
    -- EOT End of Token
    if E(C0, C.space) then
      D " >> EOT"
      hstream[#hstream+1] = { token = htoken, type = htype }
      htoken, htype       = "", ""
      
    -- EOL End of Line
    elseif E(C0, C.linebreak) then
      D " >> EOL"
      htoken              = htoken .. C0
      htype               = "EOL"
      hstream[#hstream+1] = { token = htoken, type = htype }
      htoken, htype       = "", ""
      _lnc                = _lnc+1
      _chplnc             = 0
    end
    --
  -- Digit decimal
  elseif E(C0, C.digits.all) then
    INUSE_turnoff_but("digit")
    D " > Digit"
      -- 0(dbxc)
    if C0 == "0" and E(C1, "bxcd") and htoken == "" then
      D " >> 0dbxc"
      if C1 == "b"     then htype = "expr:#b"
      elseif C1 == "x" then htype = "expr:#x"
      elseif C1 == "c" then htype = "expr:#c"
      elseif C1 == "d" then htype = "expr:#d"
      else                  htype = "expr:#d" end
    -- Error checking --
    elseif htype == "expr:#b" then if not E(C0, C.digits.bin) then 
      error(([[\n[nightc/lexer] Attempt to use non-binary digit in a binary number.
                 [nightc/lexer] %s
                 [nightc/lexer] %s^ char %d]]):format(
                   _line, string.rep(" ", _chplnc-1), _chc)
                 ) -- TODO Insert line
    end end
    
    -- Add to htoken
    if E(C1, "bxcd") or E(C0, "bxcd") then else
      D "/ Adding C0 to token"
      htoken = htoken .. C0
    end
  end
  _chc    = _chc+1
  _chplnc = _chplnc+1
  CI ()
  D ("= htoken "..htoken)
end
D "--------------------"
D ": Adding final token"
hstream[#hstream+1] = { token = htoken, type = htype }
htoken, htype = "", ""
D ": Cleaning tokens"
for k,v in pairs(hstream) do
  if v.type == "" then hstream[k] = nil end
end
D "====================="
print( inspect(hstream) )
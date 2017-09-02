--[[
Night | lexer/scope.lua
..... | Defines variables and scopes
..... | By daelvn (daelvn@gmail.com)
..... | MIT Licensed
]]--

-- Linter
local type, pairs, setmetatable  = type, pairs, setmetatable
local table                      = table

-- Load LPeg and constants
local lpeg = require "lpeg"
local C    = require "lexer.constants"
-- Namespace
local lex_scope = {}

-- Type inference patterns
lex_scope.inference = {
  string  = C.wspace * C.dquote * C.instring^0 * C.dquote,
  char    = C.wspace * C.squote * C.inchar   * C.squote,
  number  = C.wspace * (C.digit + lpeg.S(".e"))^1,
  hnumber = C.wspace * (lpeg.P("0x") * C.hexdigit)^1,
  onumber = C.wspace * (lpeg.P("0c") * C.octdigit)^1,
  bnumber = C.wspace * (lpeg.P("0b") * C.bindigit)^1,
  boolean = C.wspace * lpeg.P("True") + lpeg.P("False"),
  table   = C.wspace * lpeg.P("[") * C.any^0 * lpeg.P("]"),
  fn      = C.wspace * lpeg.P("(") * C.any^0 * lpeg.P(")") * C.space * -lpeg-P("::") * lpeg.P(":"),
  class   = C.wspace * lpeg.P("(") * C.any^0 * lpeg.P(")") * C.space * lpeg.P("::"),
  block   = C.wspace * lpeg.P("{") * C.any^0 * lpeg.P("}"),
}

-- Locals
function lex_scope:add_local(name, variable)
  table.insert(self.locals, variable)
  self.locals_map[name] = variable
end

function lex_scope:create_local(name, type)
  local variable = self:get_local(name)
	if variable then return variable end

  variable = {
  	Scope = self,
  	Name = name,
    Type = type,
  	IsGlobal = false,
  	CanRename = true,
  	References = 1,
  }

  self:add_local(name, variable)
  return variable
end

function lex_scope:get_local(name)
  repeat
		local variable = self.locals_map[name]
		if variable then return variable end


		self = self.Parent
  until not self
end

function lex_scope:get_old_local(name)
  if self.old_locals_map[name] then
		return self.old_locals_map[name]
	end
  return self:get_local(name)
end

function lex_scope:rename_local(old, new)
  old = type(old) == 'string' and old or old.Name
	repeat
		local variable = self.locals_map[old]
		if variable then
			variable.Name = new
			self.old_locals_map[old] = variable
			self.locals_map[old] = nil
			self.locals_map[new] = variable
			break
		end

		self = self.Parent
  until not self
end

-- Globals
function lex_scope:add_global(name, variable)
  table.insert(self.globals, variable)
  self.globals_map[name] = variable
end

function lex_scope:create_global(name, type)
  local variable = self:get_global(name)
	if variable then return variable end

  variable = {
  	Scope = self,
  	Name = name,
    Type = type,
  	IsGlobal = true,
  	CanRename = true,
  	References = 1,
  }

  self:add_global(name, variable)
  return variable
end

function lex_scope:get_global(name)
  repeat
		local variable = self.globals_map[name]
		if variable then return variable end


		self = self.Parent
  until not self
end

function lex_scope:get_old_global(name)
  if self.old_globals_map[name] then
		return self.old_globals_map[name]
	end
  return self:get_global(name)
end

function lex_scope:rename_global(old, new)
  old = type(old) == 'string' and old or old.Name
	repeat
		local variable = self.globals_map[old]
		if variable then
			variable.Name = new
			self.old_globals_map[old] = variable
			self.globals_map[old] = nil
			self.globals_map[new] = variable
			break
		end

		self = self.Parent
  until not self
end

-- Variables
function lex_scope:get_variable(name)
  return self:get_local(name) or self:get_global(name)
end

function lex_scope:get_variables()
  return self:_get_variables(true, self:_get_variables(true))
end

function lex_scope:_get_variables(top, ret)
  local ret = ret or {}
	if top then
		for _, v in pairs(self.Children) do
			v:_get_variables(true, ret)
		end
	else
		for _, v in pairs(self.locals) do
			table.insert(ret, v)
		end
		for _, v in pairs(self.globals) do
			table.insert(ret, v)
		end
		if self.Parent then
			self.Parent:_get_variables(false, ret)
		end
	end
  return ret
end

-- Other
function lex_scope:toString()
  return "<Scope>"
end

-- Export
local function new_lex_scope(parent)
	local scope = setmetatable({
		Parent = parent,
		locals = {},
		locals_map = {},
		globals = {},
		globals_map = {},
		old_locals_map = {},
		Children = {},
	}, { __index = lex_scope })

	if parent then
		table.insert(parent.Children, scope)
	end

	return scope
end

return new_lex_scope
--[[
Night | lexer/tokens.lua
..... | Provides functions for reading from a token stream.
..... | By daelvn (daelvn@gmail.com)
..... | MIT Licensed
]]--

-- Linter
local min    = math.min
local insert = table.insert
local ipairs = ipairs

return function(tokens)
  local n       = #tokens
  local pointer = 1
  
  local function Peek(offset)
		return tokens[min(n, pointer + (offset or 0))]
	end

	local function Get(tokenList)
		local token = tokens[pointer]
		pointer = min(pointer + 1, n)
		if tokenList then
			insert(tokenList, token)
		end
		return token
	end

	local function Is(type)
		return Peek().Type == type
	end

	local function ConsumeSymbol(symbol, tokenList)
		local token = Peek()
		if token.Type == 'Symbol' then
			if symbol then
				if token.Data == symbol then
					if tokenList then insert(tokenList, token) end
					pointer = pointer + 1
					return true
				else
					return nil
				end
			else
				if tokenList then insert(tokenList, token) end
				pointer = pointer + 1
				return token
			end
		else
			return nil
		end
	end

	local function ConsumeKeyword(kw, tokenList)
		local token = Peek()
		if token.Type == 'Keyword' and token.Data == kw then
			if tokenList then insert(tokenList, token) end
			pointer = pointer + 1
			return true
		else
			return nil
		end
	end

	local function IsKeyword(kw)
		local token = Peek()
		return token.Type == 'Keyword' and token.Data == kw
	end

	local function IsSymbol(symbol)
		local token = Peek()
		return token.Type == 'Symbol' and token.Data == symbol
	end

	local function IsEof()
		return Peek().Type == 'Eof'
	end

	local function Print(includeLeading)
		includeLeading = (includeLeading == nil and true or includeLeading)

		local out = ""
		for _, token in ipairs(tokens) do
			if includeLeading then
				for _, whitespace in ipairs(token.LeadingWhite) do
					out = out .. whitespace:Print() .. "\n"
				end
			end
			out = out .. token:Print() .. "\n"
		end

		return out
  end
end
# Parameters
(<type> <identifier> (= <expr>)?,...)

# Block
{<stat>+}

# Expr: Classes
<identifier> (<operator> <identifier>)? <parameters> :: <block>
<parameters> = (...?)
<block> = {...} or Block <block>
<operator> = \<-

# Expr: Functions
<identifier> <parameters> : <block>
<parameters> = (...?)
<block> = or Block <block>

# Stat: Comments
// content
/* content */
// content //

# Stat: Operators
<type>? <identifier> <operator> <expr>

# Expr: Table
[<key> <expr>,...]

# Expr: String, char, symbol
"<string_content>"
'<char_content>'
:<symbol_content>

# Expr: Digits
<digit>*

# Lexer hierarchy
## Example code
```night
Integer a = 1

#ControlA () :: {
  
}
```
-- : for class (expr:Digit, digit expression)
-- :: for type (op::numeric, numeric ops)
expr:Digit a
  > op::numeric
    > expr:Digit b - type b = type a

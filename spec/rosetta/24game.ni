// Import math.random
Function random = use ( :math ).random

List numbers = [
  random (1,9).toChar (),
  random (1,9).toChar (),
  random (1,9).toChar (),
  random (1,9).toChar ()
]
List used = []

map (numbers, uprint!) // Unsafe print, coerces the variables

write! ( "Input a RPN expression that results in 24: " )
String input = read!

Stack rpn = []

input.chars.iterate (Char c) {
  switch (c)
  (numbers.match) {
    if (used.match (c)) {
      rpn.push (c)
      used.append (numbers.indexOf (c))
    }
  }
    ('+') {
      Char na = rpn.pop ()
      Char nb = rpn.pop ()
      Integer nc = na.toNumber () + nb.toNumber ()
      rpn.push (nc.toChar ())
    }
    ('-') {
      Char na = rpn.pop ()
      Char nb = rpn.pop ()
      Integer nc = na.toNumber () - nb.toNumber ()
      rpn.push (nc.toChar ())
    }
    ('*') {
      Char na = rpn.pop ()
      Char nb = rpn.pop ()
      Integer nc = na.toNumber () * nb.toNumber ()
      rpn.push (nc.toChar ())
    }
    ('/') {
      Char na = rpn.pop ()
      Char nb = rpn.pop ()
      Integer nc = na.toNumber () + nb.toNumber ()
      rpn.push (nc.toChar ())
    }
    // Other characters get ignored
 }

Function fn = (Integer i, Block b) : {
  run_something (i, b)
}
fn (Integer i) : {
  // code
}

// Calling
fn ()
fn (1)

// Composition with code blocks
fn (1) {
  // code
}
//--------//
fn (1, {
  // code
})

// Composition with other functions
fn (1, _) <| other_function (2)
//--------//
fn (1, other_function (2))

// Composition with comma
fn (1, _) <|
  other_function (2)
//--------//
fn (1, other_function (2))

// Lambdas
exec_lambda (Function lambda) : {
  lambda ()
}
exec_lambda (
  () : { io.print("Hello, lambdas!") }
)

// Infix functions
a .fn b



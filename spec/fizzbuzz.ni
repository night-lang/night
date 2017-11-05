// fizzbuzz.ni
for (Integer i, 1, 100) {
  if (i % 15 == 0) {
    print! ("FizzBuzz")
  } (i % 3 == 0) {
    print! ("Fizz")
  } (i % 5 == 0) {
    print! ("Buzz")
  } { // Else
    print! (i0)
  }
}
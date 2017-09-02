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

for i = 1, 100 do
	if i % 15 == 0 then
		print("FizzBuzz")
	elseif i % 3 == 0 then
		print("Fizz")
	elseif i % 5 == 0 then
		print("Buzz")
	else
		print(i)
	end
end
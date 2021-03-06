Class Person = (String name, Integer age) :: {
  String self.name = name
  String self.age  = age
}

Person (Person self, String phrase) : {
  print! (self.name .. ": " .. phrase)
}

Person daelvn = Person ("Dael", "14")
daelvn:say ("Hello, world!")

// Extends
Shape (String color) :: {
  String self.color = color
}

Square <- Shape (Integer sides) :: {
  Integer self.sides = sides
}

// Implements
Interface ITalk = [
  :say (Object self, String phrase) : {
    print! (self.name .. ": " .. phrase)
  },
  :greet (Object self) : {
    print! (
      self.name .. 
      ": Hello!, I am " ..
      self.name .. 
      ", and I'm " ..
      self.age.toString ()
    )
  }
]

Class Person = (String name, Integer age) :: {
  String self.name = name
  String self.age  = age
}
Person <+ ITalk


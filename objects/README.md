# Object-Oriented Features for R5RS

This documentation explains only how to use the functions provided by this library; it does not explain the inner workings or how it was implemented. This documentation explains the syntax for each provided function, and at the end there are a number of examples.

## Members

In the below functions, `<id>` is some symbol, and `<value>` is either a function or a built-in Scheme object. Note that, if it's a function, it should always expect the first argument it receives to be a reference to the object calling it. `<obj>` is a procedure that represents an object, and it *must* be distinguished from normal methods because, unlike methods, object members will not be implicitly passed a reference to the calling object.

Note that members with a procedure or object value will always be immutable, regardless of the declaration function you use.

|Function|Syntax|Purpose|
|-|-|-|
|`public`|`(public <id> <value>)`|Declares a public immutable member.|
|`private`|`(private <id> <value>)`|Declares a private and immutable member.|
|`public-mut`|`(public <id> <value>)`|Declares a public mutable member.|
|`private-mut`|`(public <id> <value>)`|Declares a private mutable member.|
|`public-obj`|`(public <id> <obj>)`|Declares a public object member.|
|`private-obj`|`(public <id> <obj>)`|Declares a private object member.|

### Example

```scheme
(define point-class (class
  (public-mut `x 0)
  (public-mut `y 0)
  (private-mut `secret-x 42)
  (private `secret-y (lambda (self) 
    (* (self `x) (self `y))
  ))
))
```

## Classes

Below, `<class>` refers to some list of members and `<member>` refers to some member.

|Function|Syntax|Purpose|
|-|-|-|
|`class`|`(class [<member>, [<member>, [<member, [...]]])`|Declares a class with a number of members.|
|`compose`|`(compose <class>, [<superclass>, [<superclass>, []...]]])`|Declares a class with all members of each provided class. If two or more of the provided classes have identical members, the leftmost class's implementation is used.|

### Example

```scheme
(define colored-class (class
  (public `color `red)
))

(define colored-point-class 
  (compose colored-class point-class)
)
```

## Instantiation

|Function|Syntax|Purpose|
|-|-|-|
|`new`|`(new <class>)`|Instantiates the provided class, returning an object.|
|`array`|`(array <class> <length>)`|Returns an array of instances of the provided class.|

```scheme
(define point (new point-class))
(define points (array point-class 10))
```

## Instances

Instances are represented with functions. With these functions, you can use the following syntaxes to interact with their members.

|Call|Purpose|
|-|-|
|`(<obj> <id>)`|If the member with the corresponding `id` is a built-in Scheme object/primitive, the value of the member is returned. If the member is a method, it is invoked with no arguments except the reference to this `obj`. If the member is an object, an error is caused because objects cannot be called without any arguments.|
|`(<obj> <id> [args...])`|If the member is a built-in Scheme object/primitive, the value of the member is assigned the value of the *last* `arg`. If the member is a method, it is invoked with the reference to this `obj` and each `arg`. If the member is an object, the object is invoked with the `args` as arguments.|
|`(<array> <index>)`|Unlike the other calls, this one can take a number as the first argument, instead of an identifying symbol. This type of call is only meant for arrays and can create errors if used on a non-array object. It indexes the array and returns the element.|

```scheme
;; Accessing object fields
(display (point `x)) ; prints 0
(display (point `y)) ; prints 0

;; Modifying object fields
(point `x 5)
(point `y 10)

;; Invoking a method
(display (point `secret-y)) ; prints 50
```

The following are built-in methods of objects.

|Method|Syntax|Purpose|
|-|-|-|
|`to-string`|```(<obj> `to-string)```|Returns a string representation of the object. The string describes the object in a C-like syntax.|
|`class`|```(<obj> `class)```|Returns a reference to the original class used to instantiate the object.|

The following are built-in methods of arrays. Note that arrays are objects, so they also have the built-in methods described above.

|Method|Syntax|Purpose|
|-|-|-|
|`length`|```(<arr> `length)```|Returns the length of the array.|
|`for-each`|```(<arr> `for-each <callback)```|Invokes the callback function for each element. The callback should expect two elements: the current element, and it's index (in that order).|

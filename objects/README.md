# Object-Oriented Features for R5RS

This documentation explains only how to consume the functions provided by this library; it does *not* explain the inner workings or how it was implemented.

## Syntax

### Members

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

### Classes

Below, `<class>` refers to some list of members and `<member>` refers to some member.

|Function|Syntax|Purpose|
|-|-|-|
|`class`|`(class [<member>, [<member>, [<member, [...]]])`|Declares a class with a number of members.|
|`compose`|`(compose <class>, [<superclass>, [<superclass>, []...]]])`|Declares a class with all members of each provided class. If two or more of the provided classes have identical members, the leftmost class's implementation is used.|

### Instantiation

|Function|Syntax|Purpose|
|-|-|-|
|`new`|`(new <class>)`|Instantiates the provided class, returning an object.|
|`array`|`(array <class> <length>)`|Returns an array of instances of the provided class.|

### Instances

Instances are represented with functions. With these functions, you can use the following syntaxes to interact with their members.

|Call|Purpose|
|-|-|
|`(<obj> <id>)`|If the member with the corresponding `id` is a built-in Scheme object/primitive, the value of the member is returned. If the member is a method, it is invoked with no arguments except the reference to this `obj`. If the member is an object, an error is caused because objects cannot be called without any arguments.|
|`(<obj> <id> [args...])`|If the member is a built-in Scheme object/primitive, the value of the member is assigned the value of the *last* `arg`. If the member is a method, it is invoked with the reference to this `obj` and each `arg`. If the member is an object, the object is invoked with the `args` as arguments.|
|`(<array> <index>)`|Unlike the other calls, this one can take a number as the first argument, instead of an identifying symbol. This type of call is only meant for arrays and can create errors if used on a non-array object. It indexes the arrayand returns the element.|

## Overview

This library is imported like so:

```scheme
(#%require "objects/index.rkt")
```

Doing this brings in the following functions:

### `public`, `public-mut`, `private`, `private-mut`, `public-obj`, and `private-obj`

These functions are used in class declarations to represent various types of members. For example,

```scheme
(class
  (public-mut `x 0)
)
```

defines a class with a single field, `x`, that holds a mutable number initialized to `0`. In these functions, the `mut` suffix means "mutable", and `obj` means "object". Objects *must* be included with an `obj` function, otherwise the program will break.

Members are immutable by default, unless they were declared with a `public-mut` or `private-mut`. Members that are procedures (i.e., objects and methods) are always immutable, regardless of the declaration you use. Note that an immutable object can still change it's properties, it just cannot be reassigned.

### `class` and `compose`

As shown in the previous example, `class` is used to define a template for objects by passing it a series of member declarations.

E.g.,

```scheme
(define point (class
  (public-mut `x 0)
  (public-mut `y 0)
  (public `to-vector (lambda (this)
    (vector (this `x) (this `y))
  ))
))
```

This defines a class with two mutable public properties, `x` and `y`, as well as a method `to-vector`.

The `compose` function exists as an implementation of multiple inheritance. Instead of "extending" a superclass in a class definition, you can instead create new classes with the `compose` function. E.g.,

```scheme
(define class-a (class ...))
(define class-b (class ...))
(define class-c (class ...))
(define composite-class (compose class-a class-b class-c))
```

`composite-class` is a class that has all members of each of it's components. In this example, `class-a` members override `class-b` and `class-c`, and `class-b` overrides `class-c`.

`compose` can take any number of classes.

### `new`

The `new` function is used to instantiate a class. The interface for working with a class is like so:

- To get a property (non-function member), use ```(obj `id)``` where `obj` is some instance created by `new`, and `id` is the identifier of one of it's properties.
- To set a property, use ```(obj `id new-value)```.

Methods, i.e., members that are functions, are treated differently.

- To invoke a method, use ```(obj `id [args])```. This invokes the method with a `this` reference as it's first argument and `args` as the subsequent arguments. 

E.g.,

```scheme
(define point (class
  (public-mut `x 0)
  (public-mut `y 0)
  (public `to-vector (lambda (this)
    (vector (this `x) (this `y))
  ))
))

(define p (new point))

(p `x 9)
(p `y 3)

(p `to-vector) ;=> #(9 3)
```

This example shows a method which takes no arguments. You could also implement methods that do more than one argument. E.g.,

```scheme
(define point (class
  (public-mut `x 0)
  (public-mut `y 0)
  (private-mut `z 0)
  (public `set-z (lambda (this new-z)
    (this `z new-z)
  ))
  (public `get-z (lambda (this)
    (this `z)
  ))
))
```

This also demonstrates how methods have access to private methods.

All objects have access to predefined (and overridable) members. These members include the following.

- `to-string`: Returns a string representation of the object and it's state. The string looks like a C-style class and is meant to help with debugging.
- `class`: Returns a reference to the original class that the object was instantiated with. Therefore, you can compare two object's types with something like:

```scheme
(equal? (obj1 `class) (obj2 `class))
```

This technique also enables polymorphism, *or* identity-based class comparison, depending on which equivalence predicate you use.

### `array`

The `array` function is an alternative to `new` for creating arrays. Arrays are internally represented as vectors to ensure the expected algorithmic complexity.

`array` can be used like so:

```scheme
(array <class> <length>)
```

`array` currently *requires* a class; i.e., it cannot be implemented with primitives. If you want an array of primitives, you should just use a vector.

Arrays created this way are homogenous, and their members and length are immutable. Note that immutable objects can still be manipulated, but not reassigned.

`array`s can be indexed like so:

```scheme
(define point (class
  (public-mut `x 0)
  (public-mut `y 0)
  (public `to-vector (lambda (this)
    (vector (this `x) (this `y))
  ))
))

(define arr (array point 100))

((arr 0) `x 99)
```

This code creates an array of `point` objects, and then mutates the zeroth `point` by setting it's `x` property to `99`.

Indexing will never cause an error. Negative values are treated as distance from the end, i.e., the index `-1` and `0` are equivalent. Indexes that are out of bounds will always return `undefined`.

In addition to indexing, arrays also have the following built-in properties (note that they also have the built-in properties of objects such as `to-string`, since they *are* objects):

- `vector`: A property representing the array as a vector.
- `length`: The length of the array.
- `for-each`: A method that takes a single argument that is a callback function. The callback is executed for each element and should take two arguments; the current element and it's index.

E.g.,

```scheme
(define point (class
  (public-mut `x 0)
  (public-mut `y 0)
  (public `to-vector (lambda (this)
    (vector (this `x) (this `y))
  ))
))

(define arr (array point 100))

((arr -1) `x 99)
(arr `for-each 
  (lambda (p i) 
    (display i) 
    (newline) 
    (display (p `to-string))
  )
)
```

This example sets the last `point`'s `x` property to `99`, and then displays each `point` in the array.
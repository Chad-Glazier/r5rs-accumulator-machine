# Object-Oriented Programming in Scheme

This library provides a minimal implementation of key object-oriented programming concepts as a set of functions. This system is not meant to exactly replicate other language's object systems, and is distinct in some fundamental ways.

<ul>
  <li><a href="#basic-usage">Basic Usage</a></li>
  <ul>
    <li><a href="#defining-members">Defining Members</a></li>
    <li><a href="#creating-objects">Creating Objects</a></li>
    <li><a href="#interacting-with-objects">Interacting with Objects</a></li>
    <li><a href="#backdoors-for-object-members">Backdoors for Object Members</a></li>
  </ul>
  <li><a href="#polymorphism-and-forms">Polymorphism and Forms</a></li>
  <li><a href="#inheritance-and-polymorphs">Inheritance and Polymorphs</a></li>
  <li><a href="#built-in-methods">Built-In Methods</a></li>
  <ul>
    <li><a href="#object-and-method">`object?` and `method?`</a></li>
    <li><a href="#creating-objects">`new` and `clone`</a></li>
    <li><a href="#form">`form`</a></li>
    <li><a href="#form-to-string">`form-to-string`</a></li>
    <li><a href="#subset-of-and-superset-of">`subset-of?` and `superset-of?`</a></li>
    <li><a href="#to-string">`to-string`</a></li>
  </ul>
</ul>

## Basic Usage

This section contains a brief overview of the basic usage of functions in this library to create and interact with objects.

### Defining Members

Each object is composed of *members*, which are returned by special functions. These functions are:

```scheme
; define a public/private member; either an object or a non-lambda Scheme object.
(public <identifier> [<initial-value>])
(private <identifier> [<initial-value>])

; define an immutable public/private member; either an object or a non-lambda 
; Scheme object.
(public-readonly <identifier> [<initial-value>])
(private-readonly <identifier> [<initial-value>])

; define a public/private method, which should be a lambda expression that takes
; at least one argument that represents a reference to the calling object.
(public-method <identifier> <initial-value>)
(private-method <identifier> <initial-value>)
```

### Creating Objects

Each object is created with one of three functions, each one operating on a sequence of members. To demonstrate these functions, I will first define a couple of example classes. In this system, a "class" is really just a list of members.

```scheme
(define point (list
  (private `x 0)
  (private `y 0)
  (public-method `vector (lambda (this)
    (vector
      (this `x)
      (this `y)
    )
  ))
))

(define colored (list
  (public `color "red")
))
```

Then, to instantiate these, you can use the following functions.

```scheme
; to implement multiple classes
(define green-point (polymorph colored point))
(green-point `color "green")

; to implement one class
(define c (new colored))

; to implement something without a class
(define blue-point-2 (object
  (private `x 0)
  (private `y 0)
  (public `color "blue")
  (public-method `vector (lambda (this)
    (vector
      (this `x)
      (this `y)
    )
  ))
))
```

In this example, we've created three objects. We can print them all out with the built-in `to-string` method of objects,

```scheme
(display (c `to-string))
(newline)
(display (green-point `to-string))
(newline)
(display (blue-point `to-string))
(newline)
```

to produce the following output.

```ts
{
  public color: string = "red"
}
{
  public color: string = "green"
  private x: number = 0
  private y: number = 0
  public vector: method
}
{
  public color: string = "blue"
  private x: number = 0
  private y: number = 0
  public vector: method
}
```

Another built-in way to print objects is to print just their "form", which refers to their public members, ignoring values. E.g.,

```scheme
(display (c `form-to-string))
(newline)
(display (green-point `form-to-string))
(newline)
(display (blue-point `form-to-string))
(newline)
```

Produces the following output.

```ts
{
  color: string
}
{
  color: string
  vector: method
}
{
  color: string
  vector: method
}
```

### Interacting with Objects

There are three distinct types of members that can be found on an object:

- methods,
- objects, and
- built-in Scheme objects such as `number`, `boolean`, `string`, `list`, etc.

These three different types are handled in their own way when using an object, but interacting with an object will always follow this structure:

```scheme
(<object> <identifier> [...<optional-arguments>])
```

A call like this is handled based on the type of the member that matches the `identifier` you've provided.

If the member is a built-in Scheme object and you've provided *zero* `optional-arguments`, then the value of that member is returned. However, if you do provide `optional-arguments`, the value of the *last* optional argument will be used to set the value of the member. E.g.,

```scheme
(define obj (object
  (public `x)
  (public `y)
))

(obj `x)    ;=> `undefined
(obj `x 3)
(obj `x)    ;=> 3
```

If the member is a method, then the method will be invoked with the first argument being a reference to the `object`, and subsequent arguments being the `optional-arguments`. E.g.,

```scheme
(define obj (object
  (private `x)
  (public `get-x (lambda (this)
    (this `x)
  ))
  (public `set-x (lambda (this new-x)
    (this `x new-x)
  ))
))

(obj `get-x)    ;=> `undefined
(obj `set-x 3)
(obj `get-x)    ;=> 3
```

Objects are treated the same way, except that they don't receive a reference to the calling object. E.g.,

```scheme
(define obj (object
  (public `x 0)
  (public `nested-object (object
    (private `x 1)
    (public `get-x (lambda (this)
      (this `x)
    ))
  ))
))

(obj `nested-object `get-x) ;=> 1
```

### Backdoors for Object Members

In some cases, these accessing rules will get in the way of doing certain things. For example, reassigning a function or an object, or setting a read-only variable. These cases should be avoided because they usually indicate a bigger problem that needs to be resolved, but if you *must* work around this accessing system for band-aid fixes, you always have access to the special object methods `get` and `set!`:

```scheme
(define obj (object
  (public `x 0)
  (public `nested-object (object
    (private `x 1)
    (public `get-x (lambda (this)
      (this `x)
    ))
  ))
))

(obj `get `nested-object)  ;=> #<procedure>
(obj `set! `nested-object 4)
(obj `get `nested-object)  ;=> 4
```

Now, you've seen enough to be able to work with basic objects. The following sections of this document explain how common object-oriented concepts are supported by this system.

## Polymorphism and Forms

Polymorphism is supported by this system by the way the objects are compared. Each object has a "form" which represents the object as a series of members, and each member is represented by an identifier and a type. In order to compare the form of two objects, two functions are provided.

```scheme
(define a (object
  (public `x 0)
  (public `y 0)
))

(define b (object
  (public `x -1)
  (public `y -1)
  (public `z -1)
))

(object::subset? a b)   ; #t, because every public member of `a` exists on `b`
(object::superset? a b) ; #f, because `z` is not found on `a`.
```

The terms "subset" and "superset" do not refer to proper sub- or super-sets. I.e., if two objects share the exact same form, they will both be sub- and super-sets of each other.

Note that objects also have built-in methods to perform this comparison in a slightly more concise way.

```scheme
(a `subset-of? b)   ; #t
(a `superset-of? b) ; #f
```

The comparison of two objects in this way is recursive, so each nested object member will also be compared. Additionally, it's important to remember that forms only represent *public* members.

The form of any object or list of members can be directly obtained with:

```scheme
; getting the form from an object
(object->form <obj>)
; or
(<obj> `form)

; getting the form from a list of members
(members->form (list 
  (public `x 0) 
  ...
))
```

From there, forms can be compared with:

```scheme
(form::subset? <form-a> <form-b>)
(form::superset? <form-a> <form-b>)
```

## Inheritance and Polymorphs

In this system, a "class" is merely a list of members. Lists of members can be instantiated like so:

```scheme
(define point (list
  (public `x 0)
  (public `y 0)
))

(define p (new point))
```

Multiple classes can be implemented at once with:

```scheme
(define colored (list
  (public `color "red")
))

(define colored-point (polymorph colored point))
```

Additionally, if you're just concerned with "inheritance", you can combine two classes with the `members::add-members` function.

```scheme
(define colored-point-class (members::add-members colored point))

(define colored-point-2 (new colored-point-class))
```

Another way to extend the form of an object is with the `add-members` method:

```scheme
; this doesn't mutate `p`
(define colored-point-3 (p `add-members colored))
```

Now, the `colored-point-1`, `-2` and `-3` objects all share the same form.

## Built-In Methods

Throughout the above examples, a few built-in methods of objects were explained. Below, they are more thoroughly explained. 

It's also important to note that all of these methods cannot be overridden. You may set members with the same identifiers without causing an error, but they will never be accessed.

### `object?` and `method?`

Syntax:

```scheme
(<obj> `object?) ;=> #t
(<obj> `method?) ;=> #f
```

`object?` always returns `#t` on objects, just as `method?` always returns `#f`. These are used internally by the system to distinguish functions that represent objects and those that represent methods. This configuration is why you *must* declare methods with `-method` functions to avoid unexpected behavior.

### `new` and `clone`

Syntax:

```scheme
(<obj> `new)    ;=> new object
(<obj> `clone)  ;=> clone
```

The `new` returns a new version of the object, based on the original members that it was made with. The `clone` method works the same way, except the new object is defined by the current state of the object being cloned.

With these functions, every object can be treated as a prototype.

### `form`

Syntax:

```scheme
(<obj> `form)
; equivalent to
(object->form <obj>)
```

This method returns the form of an object, which is represented as a list of pairs. Each pair represents a member's identifier and its type. The identifier is always a symbol, and the "type" is either a symbol (for built-in Scheme types) or a nested list of pairs to represent the form of a nested object.

### `form-to-string`

Syntax:

```scheme
(<obj> `form-to-string)
; equivalent to
(form->string (object->form <obj>))
```

This function returns a string representation of an object's form. E.g.,

```rust
{
  a: vector
  b: list
  nested-object: {
    x: number
    y: string
    z: number
  }
}
```

### `subset-of?` and `superset-of?`

Syntax:

```scheme
(<obj1> `subset-of? <obj2>)
; equivalent to
(object::subset-of? <obj2>)

(<obj1> `superset-of? <obj2>)
; equivalent to
(object::superset-of? <obj2>)
```

These methods look at the forms of the operand objects and perform a deep comparison on them. If all elements of `<obj1>`'s form are found in `<obj2>`'s form, then it's said that `<obj1>` is a subset of `<obj2>`. Note that this includes improper subsets (equal forms are considered subsets of each other). Conversely, `<obj1>` is said to be the superset of `<obj2>` if every element of `<obj2>`'s form is found in `<obj1>`'s form.

These functions can be used to determine whether an object meets an interface. E.g.,

```scheme
(define can-bark (object
  (public-method `bark `undefined) ; the implementation is irrelevant
))

(define dog (object
  (public `name "Balto")
  (public-method `bark (lambda (this)
    (display "woof\n")
  ))
))

(dog `superset-of? can-bark) ;=> #t
```

### `to-string`

Syntax

```scheme
(<obj> `to-string)
; equivalent to
(object->string <obj>)
```

This returns a string representation of the object. Unlike <a href="#form-to-string">`form-to-string`</a>, this string includes the private members of the object as well as their specific values. E.g.,

```rust
{
  public a: vector = #(apple "bottom" ('j' 'e' 'a' 'n' 's'))
  public b: list = (el-1 "el-2" 3)
  public nested-object: object = {
    public x: number = 0
    public y: string = "1"
    public z: number = 2
  }
}
```

# `@Using` Macro
The `@Using` macro generates the `subscript` automatically for the property employing `@dynamicMemberLookup`.

## Installation
```Swift
.package(url: "https://github.com/rokon-uddin/SwiftUsing.git", branch: "main")
```
### The example below demonstrates how the `@Using` macro streamlines the code by eliminating unnecessary boilerplate.

### Without `@dynamicMemberLookup`
```Swift
struct Inner {
    var title = "Hello World"
}

struct Transform {
    let point = CGPoint(x: 100, y: 100)
}

struct Outer {
    let flag = true
    var inner = Inner()
    let transform = Transform()
}


var outer = Outer()

let x = outer.inner.transform.point.x
outer.inner.title = "New title"
print(outer.transform.point.x)
```

### With `@dynamicMemberLookup`

```Swift
@dynamicMemberLookup
struct Inner {
    var title = "Hello World"
    subscript <T>(dynamicMember keyPath: WritableKeyPath<String, T>) -> T {
        get { title[keyPath: keyPath] }
        set { title[keyPath: keyPath] = newValue }
    }
}

@dynamicMemberLookup
struct Transform {
    var point = CGPoint(x: 100, y: 100)
    subscript <T>(dynamicMember keyPath: KeyPath<CGPoint, T>) -> T {
        point[keyPath: keyPath]
    }
}

@dynamicMemberLookup
struct Outer {
    let flag = true
    
    var inner = Inner()
    subscript <T>(dynamicMember keyPath: WritableKeyPath<Inner, T>) -> T {
        get { inner[keyPath: keyPath] }
        set { inner[keyPath: keyPath] = newValue }
    }
    
    let transform = Transform()
    subscript <T>(dynamicMember keyPath: KeyPath<Transform, T>) -> T {
        transform[keyPath: keyPath]
    }
}


var outer = Outer()
outer.title = "New title"
print(outer.x)

```
### With `@Using`
```Swift
@dynamicMemberLookup
struct Inner {
    @Using
    var title = "Hello World"
}

@dynamicMemberLookup
struct Transform {
    @Using
    var point = CGPoint(x: 100, y: 100)
}

@dynamicMemberLookup
struct Outer {
    let flag = true
    
    @Using
    var inner = Inner()
    
    @Using
    let transform = Transform()
}


var outer = Outer()
outer.title = "New title"
print(outer.x)
```


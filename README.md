# VTree

VirtualDOM for Swift (iOS, macOS), inspired by [Matt-Esch/virtual-dom](https://github.com/Matt-Esch/virtual-dom) and [elm-lang/virtual-dom](https://github.com/elm-lang/virtual-dom).

See [inamiy/SwiftElm](https://github.com/inamiy/SwiftElm) for practical use.

## Pseudocode

```swift
// ===== VTree.framework =====

protocol VTree {
    ...
    var children: [VTree] { get }
}

struct VView: VTree { ... }   // Virtual UIView
struct VLabel: VTree { ... }  // Virtual UILabel
...

// ========= Example =========

typealias State = Int  // can be any type

// Generate immutable `VTree` from `State`.
func render(state: State) -> VTree {
    return VView(children: [
        VLabel(text: "\(state)")
    ])
}

// Initialize `State`, `VTree`, and `UIView`.
var state = 0
var tree = render(state)
var view = createView(tree)

// Update logic: Timer updates `state` and re-render.
timer(1) {
    state += 1
    let newTree = render(state)
    let patch = diff(old: tree, new: newTree)
    view = apply(patch: patch, to: view)
}
```

This is an example of `timer` updating a count in `view.label`.

Unlike setting `view.label.text = "\(state)"` or any data bindings e.g. reactive programming that directly mutates variables from _all over the place_, **`VTree` minimizes such side-effects** by:

1. Generating an immutable `VTree` from a single `state`
2. Calculating a `patch` using an efficient `diff` algorithm, and 
3. Mutating a `view` only by calling `apply`

This seems like too much calculation for just tweaking a single variable, but **it eventually prevents us from making stupid side-effects that is the 99% cause of our app's bugs**.

Above code is just a pseudocode for simple `protocol VTree`.
For better type-safety, `protocol VTree` will require `associatedtype` and also [type-erasure techinique](https://realm.io/news/tryswift-gwendolyn-weston-type-erasure/).

Please see [Tests/DiffSpec.swift](Tests/DiffSpec.swift) for more examples.

## Metaprogramming with [Sourcery](https://github.com/krzysztofzablocki/Sourcery)

VTree uses [Sourcery](https://github.com/krzysztofzablocki/Sourcery) as Swift template metaprogramming engine to cover transcripting that [elm-lang/core](https://github.com/elm-lang/core) does when converting `enum MyMsg` to JavaScript.

By using [Scripts/generate-message.sh](Scripts/generate-message.sh), VTree will support `AutoMessage` to auto-generate `extension MyMsg: Message`. **This is a requisite for VTree when interacting Cocoa events with user's `enum Msg`**. 

```bash
# Usage: ./generate-message.sh <source_dir> <code-generated-dir>
$ ./path/to/VTree/Scripts/generate-message.sh ./Demo/Sources ./Demo/Sources/CodeGenerated/
```

So that user can simplify `enum MyMsg` as:

```swift
enum MyMsg: AutoMessage {
    // NOTE: `MessageContext` is always required when enum-case (value constructor) requires arguments.
    case tap(GestureContext)
    case pan(PanGestureContext)
}
```

## Feature

- [x] ~~Handle more complicated cocoa events e.g. mouse, gesture, keyboard.~~ [MessageContext](Sources/MessageContext.swift)
- [x] ~~Add better layouting system, e.g. CSS Flexbox.~~ [inamiy/Flexbox](https://github.com/inamiy/Flexbox)
- [ ] Create more `VTree` concrete types for virtual `UI***View`.

## License

[MIT](LICENSE)

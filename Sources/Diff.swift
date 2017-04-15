import Flexbox

/// Create `Patch` by diff-ing `oldTree` and `newTree`.
public func diff<OldTree: VTree, NewTree: VTree, Msg: Message>(old oldTree: OldTree, new newTree: NewTree) -> Patch<Msg>
    where OldTree.MsgType == Msg, NewTree.MsgType == Msg
{
    let oldTree_ = *oldTree

    var steps = Patch<Msg>.Steps()
    var flexboxFrames = FlexboxFrames()
    _diffTree(old: oldTree_, new: *newTree, steps: &steps, flexboxFrames: &flexboxFrames, index: 0, skipsFlexbox: false)

    return Patch(oldTree: oldTree_, steps: steps, flexboxFrames: flexboxFrames)
}

private func _diffTree<Msg: Message>(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>, steps: inout Patch<Msg>.Steps, flexboxFrames: inout FlexboxFrames, index: Int, skipsFlexbox: Bool)
{
    guard oldTree._rawType == newTree._rawType else {
        _appendSteps(&steps, step: .replace(newTree), at: index)
        return
    }

    _diffProps(old: oldTree, new: newTree, steps: &steps, index: index)
    _diffHandlers(old: oldTree, new: newTree, steps: &steps, index: index)
    _diffGestures(old: oldTree, new: newTree, steps: &steps, index: index)

    var skipsFlexbox = skipsFlexbox
    _diffFlexbox(old: oldTree, new: newTree, steps: &steps, flexboxFrames: &flexboxFrames, skipsFlexbox: &skipsFlexbox, index: index)

    _diffChildren(old: oldTree.children, new: newTree.children, steps: &steps, flexboxFrames: &flexboxFrames, skipsFlexbox: skipsFlexbox, parentIndex: index)
}

private func _diffProps<Msg: Message>(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>, steps: inout Patch<Msg>.Steps, index: Int)
{
    let oldProps = oldTree.props
    let newProps = newTree.props

    var removes = [String]()
    var updates = [String: Any]()
    var inserts = newProps

    for (oldKey, oldValue) in oldProps {
        if let newValue = inserts.removeValue(forKey: oldKey) {
            if !_objcEqual(oldValue, newValue) {
                updates[oldKey] = newValue
            }
        }
        else {
            removes.append(oldKey)
        }
    }

    if !(removes.isEmpty && updates.isEmpty && inserts.isEmpty) {
        _appendSteps(&steps, step: .props(removes: removes, updates: updates, inserts: inserts), at: index)
    }
}

private func _diffHandlers<Msg: Message>(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>, steps: inout Patch<Msg>.Steps, index: Int)
{
    let oldHandlers = oldTree.handlers
    let newHandlers = newTree.handlers

    var removes = [SimpleEvent]()
    var updates: HandlerMapping<Msg> = [:]
    var inserts = newHandlers

    for (oldKey, oldValue) in oldHandlers {
        if let newValue = inserts.removeValue(forKey: oldKey) {
            if !_objcEqual(oldValue, newValue) {
                updates[oldKey] = newValue
            }
        }
        else {
            removes.append(oldKey)
        }
    }

    if !(removes.isEmpty && updates.isEmpty && inserts.isEmpty) {
        _appendSteps(&steps, step: .handlers(removes: removes, updates: updates, inserts: inserts), at: index)
    }
}

private func _diffGestures<Msg: Message>(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>, steps: inout Patch<Msg>.Steps, index: Int)
{
    let oldGestures = oldTree.gestures
    let newGestures = newTree.gestures

    var removes = [GestureEvent<Msg>]()
    var inserts = newGestures

    for oldGesture in oldGestures {
        if inserts.contains(oldGesture) {
            inserts.remove(at: inserts.index(of: oldGesture)!)
        }
        else {
            removes.append(oldGesture)
        }
    }

    if !(removes.isEmpty && inserts.isEmpty) {
        _appendSteps(&steps, step: .gestures(removes: removes, inserts: inserts), at: index)
    }
}

internal func _diffFlexbox<Msg: Message>(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>, steps: inout Patch<Msg>.Steps, flexboxFrames: inout FlexboxFrames, skipsFlexbox: inout Bool, index: Int)
{
    let oldChildren = oldTree.children
    let newChildren = newTree.children

    // Examine `flexboxTree` (flexbox hiearchy) and calculate `flexboxFrames` if needed.
    if !skipsFlexbox, let newFlexboxTree = newTree._flexboxTree {

        var isFlexboxDirty = oldTree._flexboxTree != newFlexboxTree
//        Debug.print("flexboxTree compared, isFlexboxDirty = \(isFlexboxDirty)")

//        Debug.print("oldTree.flexboxTree = \(oldTree.flexboxTree)\n")
//        Debug.print("newFlexboxTree = \(newFlexboxTree)\n")

        if !isFlexboxDirty {

            func arePropsKeysForMeasureChanged(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>) -> Bool
            {
                for key in newTree.propsKeysForMeasure {
                    if !_objcEqual(oldTree.props[key] as Any, newTree.props[key] as Any) {
                        return true
                    }
                }

                for (oldChild, newChild) in zip(oldTree.children, newTree.children) {
                    if arePropsKeysForMeasureChanged(old: oldChild, new: newChild) {
                        return true
                    }
                }

                return false
            }

            isFlexboxDirty = arePropsKeysForMeasureChanged(old: oldTree, new: newTree)

//            Debug.print("propsKeysForMeasure compared, isFlexboxDirty = \(isFlexboxDirty)")
        }

        if isFlexboxDirty {
            flexboxFrames[index] = calculateFlexbox(newFlexboxTree)
        }

        // NOTE:
        // The topmost "vtree with flexbox" has calculated all descendent flexboxes
        // at this point (`isFlexboxDirty` doesn't matter), so turn on the
        // skipping flag to avoid re-calculation for the descendent traversal.
        skipsFlexbox = true
    }

}

internal func _diffChildren<Msg: Message>(old oldChildren: [AnyVTree<Msg>], new newChildren: [AnyVTree<Msg>], steps: inout Patch<Msg>.Steps, flexboxFrames: inout FlexboxFrames, skipsFlexbox: Bool, parentIndex: Int)
{
    let (midChildren, reorder) = _reorder(old: oldChildren, new: newChildren)
    let maxCount = max(oldChildren.count, midChildren.count)
    var childCursor = parentIndex

    for i in 0..<maxCount {
        let oldChild = oldChildren[safe: i]
        let midChild = midChildren[safe: i]
        childCursor += 1

        if case let .some(.some(midChild)) = midChild {
            if let oldChild = oldChild {
                _diffTree(old: oldChild, new: midChild, steps: &steps, flexboxFrames: &flexboxFrames, index: childCursor, skipsFlexbox: skipsFlexbox)
            }
            else {
                _appendSteps(&steps, step: .insertChild(midChild), at: parentIndex)
            }
        }
        else {
            if let oldChild = oldChild {
                _appendSteps(&steps, step: .removeChild(oldChild), at: childCursor)
            }
        }

        childCursor += oldChild?.children.count ?? 0
    }

    if !reorder.isEmpty {
        _appendSteps(&steps, step: .reorderChildren(reorder), at: parentIndex)
    }
}

/// - Returns:
/// Flattened `Flexbox.Node` frames started from `flexboxTree` itself's frame
/// followed by descendent flexbox-node frames in depth-first order.
///
/// - Note:
/// This method can be called from non-main thread.
internal func calculateFlexbox(_ flexboxTree: Flexbox.Node) -> [CGRect]
{
//    Debug.print("*** calculateFlexbox ***")

    func flatten(_ layout: Flexbox.Layout) -> [CGRect]
    {
        var frames = [layout.frame]
        frames.append(contentsOf: layout.children.flatMap { flatten($0) })
        return frames
    }

    let layout = flexboxTree.layout()  // calculate Flexbox
    return flatten(layout)
}

private func _appendSteps<Msg: Message>(_ steps: inout Patch<Msg>.Steps, step: PatchStep<Msg>, at index: Int)
{
    if steps[index] == nil {
        steps[index] = []
    }
    steps[index]?.append(step)
}

/// Compare `oldChildren` and `newChildren`, then return a tuple of:
/// - `midChildren`: reordered, intermediate state of `newChildren`
/// - `reorder`: removals & insertions from `midChildren` to `newChildren`
internal func _reorder<Msg: Message>(old oldChildren: [AnyVTree<Msg>], new newChildren: [AnyVTree<Msg>]) -> (midChildren: [AnyVTree<Msg>?], reorder: Reorder)
{
    let (newKeyIndexes, newFreeIndexes) = _keyIndexes(newChildren)

    let newFreeCount = newFreeIndexes.count
    let newCount = newChildren.count

    // Exit if `newChildren` don't have any keys.
    guard newFreeCount < newCount else {
        return (midChildren: newChildren, reorder: Reorder())
    }

    let (oldKeyIndexes, oldFreeIndexes) = _keyIndexes(oldChildren)

    // Exit if `oldChildren` don't have any keys.
    guard oldFreeIndexes.count < oldChildren.count else {
        return (midChildren: newChildren, reorder: Reorder())
    }

    // e.g.
    // oldChildren = ["key1", "key2", section]
    // newChildren = [div, span, "key2", "key3", h1]
    // newKeyIndexes = ["key2": 2, "key3": 3]
    // newFreeIndexes = [0, 1, 4]

    var midChildren = [AnyVTree<Msg>?]()
    var deletedCount = 0

    // Calculate `midChildren` and `deletedCount`.
    do {
        var newFreeCursor = 0
        for oldChild in oldChildren {
            // If `oldChild` has a key, append same-key-`newChild` or `nil`.
            if let oldKey = oldChild.key {
                if let newChildIndex = newKeyIndexes[ObjectIdentifier(oldKey)] {
                    midChildren.append(newChildren[newChildIndex])
                }
                else {
                    midChildren.append(nil)
                    deletedCount += 1
                }
            }
            // If `oldChild` has no key, append no-key-`newChild` (if possible) or `nil`.
            else {
                if newFreeCursor < newFreeCount {
                    let newChildIndex = newFreeIndexes[newFreeCursor]
                    midChildren.append(newChildren[newChildIndex])
                    newFreeCursor += 1
                }
                else {
                    midChildren.append(nil)
                    deletedCount += 1
                }
            }
        }

        // e.g.
        // oldChildren = ["key1", "key2", section]
        // newChildren = [div, span, "key2", "key3", h1]
        // midChildren = [nil, "key2", div]
        // newFreeIndexes = [0, 1, 4]
        // newFreeCursor = 1

        let remainingNewCursor = newFreeCursor >= newFreeCount ? newCount: newFreeIndexes[newFreeCursor]

        do {
            var newCursor = 0
            for newChild in newChildren {
                // Append "keyed newChild" which doesn't exist in `oldChildren`.
                if let newKey = newChild.key {
                    if oldKeyIndexes[ObjectIdentifier(newKey)] == nil {
                        midChildren.append(newChild)
                    }
                }
                // Append "unkeyed newChild" which is not added yet.
                else if newCursor >= remainingNewCursor {
                    midChildren.append(newChild)
                }

                newCursor += 1
            }
        }
    }

    // e.g.
    // oldChildren = ["key1", "key2", section]
    // newChildren = [div, span, "key2", "key3", h1]
    // midChildren = [nil, "key2", div, span, "key3", h1]

    var removes: [Reorder.Remove] = [] // NOTE: Can't call `[Reorder.Remove]()` in Swift 3.0.1
    var inserts: [Reorder.Insert] = []

    // Calculate `removes` and `inserts` between `midChildren` and `newChildren`.
    do {
        let midCount = midChildren.count

        var midCursor = 0
        var newCursor = 0
        var midRemovedCount = 0 // offset adjustment for reorder-index calculation

        while newCursor < newCount {
            // Append `Remove` while `midChild` is nil.
            while midCursor < midCount && midChildren[midCursor] == nil {
                removes.append(Reorder.Remove(key: nil, from: midCursor - midRemovedCount))
                midCursor += 1
                midRemovedCount += 1
            }

            let midChild = midChildren[safe: midCursor] ?? nil
            let newChild = newChildren[newCursor]

            switch (midChild?.key, newChild.key) {

                case let (midKey?, newKey?) where midKey !== newKey:
                    // If `midChild` is same as "next newChild"...
                    if newKeyIndexes[ObjectIdentifier(midKey)] == newCursor + 1 {
                        inserts.append(Reorder.Insert(key: newKey, to: newCursor))
                        newCursor += 1
                    }
                    else {
                        removes.append(Reorder.Remove(key: midKey, from: midCursor - midRemovedCount))
                        midCursor += 1
                        midRemovedCount += 1
                    }

                // If "same key" or "neither has key"...
                case (_?, _?) /* where midKey == newKey */ :
                    fallthrough
                case (nil, nil):
                    midCursor += 1
                    newCursor += 1

                case let (nil, newKey?):
                    inserts.append(Reorder.Insert(key: newKey, to: newCursor))
                    newCursor += 1

                case let (midKey?, nil):
                    removes.append(Reorder.Remove(key: midKey, from: midCursor - midRemovedCount))
                    midCursor += 1
                    midRemovedCount += 1
            }
        }

        // e.g.
        // oldChildren = ["key1", "key2", section]
        // newChildren = [div, span, "key2", "key3", h1]
        // midChildren = [nil, "key2", div, span, "key3", h1]
        // removes =  [("nil", 0), ("key2", 0)]
        // inserts =  [("key2", 2)]
        // midCursor = 6

        // Append `Remove`s for all remainders in `midChildren`.
        while midCursor < midChildren.count {
            let midKey = midChildren[midCursor]?.key

            removes.append(Reorder.Remove(key: midKey, from: midCursor - midRemovedCount))
            midCursor += 1
            midRemovedCount += 1
        }
    }

    // If only deletion, `nil`s in `midChildren` will take care the operations, so replace to empty `Reorder`.
    if removes.count == deletedCount && inserts.isEmpty {
        return (midChildren: midChildren, reorder: Reorder())
    }
    else {
        return (midChildren: midChildren, reorder: Reorder(removes: removes, inserts: inserts))
    }
}

/// Create a tuple of "key-index-table" and "remainder (array)",
/// e.g. `trees = ["key2", div, "key1", span]` will return `(keys: ["key1": 2, "key2": 0], frees: [1, 3])`.
internal func _keyIndexes<Msg: Message>(_ trees: [AnyVTree<Msg>]) -> (keys: [ObjectIdentifier: Int], frees: [Int])
{
    var keys = [ObjectIdentifier: Int]()
    var frees = [Int]() // remaining no-key indexes

    for i in 0..<trees.count {
        if let key = trees[i].key {
            keys[ObjectIdentifier(key)] = i
        }
        else {
            frees.append(i)
        }
    }

    return (keys: keys, frees: frees)
}

/// Create `Patch` by diff-ing `oldTree` and `newTree`.
public func diff<OldTree: VTree, NewTree: VTree, Msg: Message>(old oldTree: OldTree, new newTree: NewTree) -> Patch<Msg>
    where OldTree.MsgType == Msg, NewTree.MsgType == Msg
{
    var steps = Patch<Msg>.Steps()
    _diffTree(old: *oldTree, new: *newTree, steps: &steps, index: 0)
    return Patch(oldTree: *oldTree, steps: steps)
}

private func _diffTree<Msg: Message>(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>, steps: inout Patch<Msg>.Steps, index: Int)
{
    guard oldTree._rawType == newTree._rawType else {
        _appendSteps(&steps, step: .replace(newTree), at: index)
        return
    }

    _diffProps(old: oldTree, new: newTree, steps: &steps, index: index)
    _diffHandlers(old: oldTree, new: newTree, steps: &steps, index: index)
    _diffChildren(old: oldTree.children, new: newTree.children, steps: &steps, parentIndex: index)
}

private func _diffProps<Msg: Message>(old oldTree: AnyVTree<Msg>, new newTree: AnyVTree<Msg>, steps: inout Patch<Msg>.Steps, index: Int)
{
    let oldProps = oldTree.props
    let newProps = newTree.props

    var removes = [String]()
    var updates = [String : Any]()
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

    var removes = [CocoaEvent]()
    var updates: [CocoaEvent : Msg] = [:]
    var inserts = newHandlers

    for (oldKey, oldValue) in oldHandlers {
        if let newValue = inserts.removeValue(forKey: oldKey) {
            if oldValue != newValue {
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

internal func _diffChildren<Msg: Message>(old oldChildren: [AnyVTree<Msg>], new newChildren: [AnyVTree<Msg>], steps: inout Patch<Msg>.Steps, parentIndex: Int)
{
    let reordered = _reorder(old: oldChildren, new: newChildren)
    let maxCount = max(oldChildren.count, reordered.midChildren.count)
    var childCursor = parentIndex

    for i in 0..<maxCount {
        let oldChild = oldChildren[safe: i]
        let midChild = reordered.midChildren[safe: i]
        childCursor += 1

        if case let .some(.some(midChild)) = midChild {
            if let oldChild = oldChild {
                _diffTree(old: oldChild, new: midChild, steps: &steps, index: childCursor)
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

    if !reordered.reorder.isEmpty {
        _appendSteps(&steps, step: .reorderChildren(reordered.reorder), at: parentIndex)
    }
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
    // newKeyIndexes = ["key2" : 2, "key3" : 3]
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

        let remainingNewCursor = newFreeCursor >= newFreeCount ? newCount : newFreeIndexes[newFreeCursor]

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
            let newChild = newChildren[newCursor]

            // Append `Remove` while `midChild` is nil.
            while midChildren[midCursor] == nil && midCursor < midCount {
                removes.append(Reorder.Remove(key: nil, from: midCursor - midRemovedCount))
                midCursor += 1
                midRemovedCount += 1
            }

            let midChild = midChildren[midCursor]

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

                        let nextMidChild = midChildren[midCursor]

                        // If `nextMidChild` is same as `newChild`...
                        if let nextMidKey = nextMidChild?.key, nextMidKey === newKey {
                            midCursor += 1
                            newCursor += 1
                        }
                        else {
                            inserts.append(Reorder.Insert(key: newKey, to: newCursor))
                            newCursor += 1
                        }
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
/// e.g. `trees = ["key2", div, "key1", span]` will return `(keys: ["key1" : 2, "key2" : 0], frees: [1, 3])`.
internal func _keyIndexes<Msg: Message>(_ trees: [AnyVTree<Msg>]) -> (keys: [ObjectIdentifier : Int], frees: [Int])
{
    var keys = [ObjectIdentifier : Int]()
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

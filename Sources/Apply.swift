#if os(iOS) || os(tvOS)
    import UIKit
    private let _scale = UIScreen.main.scale
#elseif os(macOS)
    import AppKit
    private let _scale = NSScreen.main()!.backingScaleFactor
#endif

/// Apply `Patch` (generated from `diff()`) to the existing real `View`.
///
/// - Returns:
///   - Same view (reused) if `view` itself is not replaced by new view or removed.
///     This reuse also occurs when `view`'s property changed or it's childrens are changed.
///   - New view (replaced)
///   - `nil` (removed)
public func apply<Msg: Message>(patch: Patch<Msg>, to view: View) -> View?
{
    let patchIndexes = patch.steps.map { $0.key }.sorted()
    let indexedViews = _indexViews(view, patchIndexes)
    var newView: View? = view

    for index in patchIndexes {
        let steps = patch.steps[index]!
        for step in steps {
            if let indexedView = indexedViews[index] {
                let appliedView = _applyStep(step, to: indexedView)
                if index == 0, let appliedView = appliedView {
                    newView = appliedView
                }
            }
        }
    }

    if let newView = newView {
        if patch.flexboxFrames.isEmpty == false {
            let flexboxFrames = patch.flexboxFrames.map { _roundFrame($0) }
            applyFlexbox(frames: flexboxFrames, to: newView)
        }
    }

    return newView
}

/// - Returns:
///   - new view, i.e. `.some(.some(newView))`
///   - removed, i.e. `.some(.none)`
///   - same view (reused), i.e. `.none`
private func _applyStep<Msg: Message>(_ step: PatchStep<Msg>, to view: View) -> View??
{
    switch step {
        case let .replace(newTree):
            let newView = newTree.createView()
            if let parentView = view.superview {
                parentView.replaceSubview(view, with: newView)
            }
            return newView

        case let .props(removes, updates, inserts):
            for removeKey in removes {
                view.setValue(nil, forKey: removeKey)
            }
            for update in updates {
                view.setValue(_toOptionalAny(update.value), forKey: update.key)
            }
            for insert in inserts {
                view.setValue(_toOptionalAny(insert.value), forKey: insert.key)
            }
            return nil

        case let .handlers(removes, updates, inserts):
            for removeEvent in removes {
                _removeHandler(for: removeEvent, in: view)
            }
            for update in updates {
                _updateHandler(msg: update.value, for: update.key, in: view)
            }
            for insert in inserts {
                _insertHandler(msg: insert.value, for: insert.key, in: view)
            }
            return nil

        case let .gestures(removes, inserts):
            for removeEvent in removes {
                _removeGesture(for: removeEvent, in: view)
            }
            for insert in inserts {
                _insertGesture(for: insert, in: view)
            }
            return nil

        case .removeChild:
            view.removeFromSuperview()
            return .some(nil)

        case let .insertChild(newTree):
            let newChildView = newTree.createView()
            view.addSubview(newChildView)
            return nil

        case let .reorderChildren(reorder):
            _applyReorder(to: view, reorder: reorder)
            return nil
    }
}

internal func applyFlexbox(frames: [CGRect], to view: View)
{
    func flatten(_ view: View) -> [View]
    {
        var views = [view]
        let subviews = view.subviews.filter { $0.isVTreeView }.flatMap { flatten($0) }
        views.append(contentsOf: subviews)
        return views
    }

    for (frame, view) in zip(frames, flatten(view)) {
        view.frame = frame
    }
}

// MARK: remove/insert handlers

private func _removeHandler(for event: SimpleEvent, in view: View)
{
    #if os(iOS) || os(tvOS)
        if case let (.control(controlEvents), view as UIControl) = (event, view) {
            view.vtree.removeHandler(for: controlEvents)
            return
        }
    #endif
}

private func _insertHandler<Msg: Message>(msg: Msg, for event: SimpleEvent, in view: View)
{
    #if os(iOS) || os(tvOS)
        if case let (.control(controlEvents), view as UIControl) = (event, view) {
            view.vtree.addHandler(for: controlEvents) { _ in
                Messenger.shared.send(AnyMsg(msg))
            }
            return
        }
    #endif
}

private func _updateHandler<Msg: Message>(msg: Msg, for event: SimpleEvent, in view: View)
{
    _removeHandler(for: event, in: view)
    _insertHandler(msg: msg, for: event, in: view)
}

// MARK: remove/insert gestures

private func _removeGesture<Msg: Message>(for event: GestureEvent<Msg>, in view: View)
{
    #if os(iOS) || os(tvOS)
        view.vtree.removeGesture(for: event)
    #endif
}

private func _insertGesture<Msg: Message>(for event: GestureEvent<Msg>, in view: View)
{
    #if os(iOS) || os(tvOS)
        view.vtree.addGesture(for: event) { msg in
            Messenger.shared.send(AnyMsg(msg))
        }
    #endif
}

// MARK: Reorder

private func _applyReorder(to view: View, reorder: Reorder)
{
    var keyViews = [ObjectIdentifier: View]()

    for remove in reorder.removes {
        let removingView = view.subviews[remove.fromIndex]
        if let removingKey = remove.key {
            keyViews[ObjectIdentifier(removingKey)] = removingView
        }
        removingView.removeFromSuperview()
    }

    for insert in reorder.inserts {
        if let insertingKey = insert.key, let insertingView = keyViews[ObjectIdentifier(insertingKey)] {
            view.insertSubview(insertingView, at: insert.toIndex)
        }
    }
}

// MARK: _indexViews

/// Create index-view-table.
private func _indexViews(_ rootView: View, _ patchIndexes: [Int]) -> [Int: View]
{
    var indexedViews = [Int: View]()
    _accumulateRecursively(
        rootView: rootView,
        rootIndex: 0,
        patchIndexes: patchIndexes,
        indexedViews: &indexedViews
    )
    return indexedViews
}

private func _accumulateRecursively(rootView: View, rootIndex: Int, patchIndexes: [Int], indexedViews: inout [Int: View])
{
    if patchIndexes.contains(rootIndex) {
        indexedViews[rootIndex] = rootView
    }

    // Early exit if subviews are not created via VTree.
    // For example, UIButton has internal UIImageView and UIButtonLabel,
    // but VTree only handles `VButton`.
    guard let firstSubview = rootView.subviews.first, firstSubview.isVTreeView == true else {
        return
    }

    var childIndex = rootIndex

    for (i, childView) in rootView.subviews.enumerated() {
        childIndex += 1

        func descendantCount(for view: View) -> Int
        {
            return view.subviews
                .filter { $0.isVTreeView }
                .reduce(0) { $0 + 1 + descendantCount(for: $1) }
        }

        let nextChildIndex = childIndex + descendantCount(for: childView)

        if _indexInRange(patchIndexes, childIndex, nextChildIndex) {
            _accumulateRecursively(
                rootView: childView,
                rootIndex: childIndex,
                patchIndexes: patchIndexes,
                indexedViews: &indexedViews
            )
        }

        childIndex = nextChildIndex
    }
}

// MARK: Helper

private func _roundFrame(_ frame: CGRect) -> CGRect
{
    func roundPixel(_ value: CGFloat) -> CGFloat
    {
        return round(value * _scale) / _scale
    }

    return CGRect(
        x: roundPixel(frame.origin.x),
        y: roundPixel(frame.origin.y),
        width: roundPixel(frame.size.width),
        height: roundPixel(frame.size.height)
    )
}

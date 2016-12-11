@testable import VTree
import Quick
import Nimble

class DiffInternalSpec: QuickSpec
{
    override func spec()
    {
        describe("_diffChildren") {

            it("key1 & key2 are swapped") {
                let oldChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "div"),
                ]
                let newChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key2),
                    *VView(key: key1),
                    *VLabel(text: "div"),
                ]

                var steps = Patch<NoMsg>.Steps()
                _diffChildren(old: oldChildren, new: newChildren, steps: &steps, parentIndex: 0)

                expect(steps.count) == 1
                expect(steps[0]) == [.reorderChildren(Reorder(removes: [(key: key2, from: 1)], inserts: [(key: key2, to: 0)]))]
            }

            it("key1 & key2 are swapped (2)") {
                let oldChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key1),
                    *VLabel(text: "div"),
                    *VView(key: key2),
                ]
                let newChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key2),
                    *VLabel(text: "div"),
                    *VView(key: key1),
                ]

                var steps = Patch<NoMsg>.Steps()
                _diffChildren(old: oldChildren, new: newChildren, steps: &steps, parentIndex: 0)

                expect(steps.count) == 1
                expect(steps[0]) == [.reorderChildren(Reorder(removes: [(key: key1, from: 0), (key: key2, from: 1)], inserts: [(key: key2, to: 0), (key: key1, to: 2)]))]
            }

            it("key1 & key2 are swapped (3)") {
                let oldChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "div"),
                ]
                let newChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key2),
                    *VLabel(text: "div"),
                    *VView(key: key1),
                ]

                var steps = Patch<NoMsg>.Steps()
                _diffChildren(old: oldChildren, new: newChildren, steps: &steps, parentIndex: 0)

                expect(steps.count) == 1
                print(steps)
                expect(steps[0]) == [.reorderChildren(Reorder(removes: [(key: key1, from: 0)], inserts: [(key: key1, to: 2)]))]
            }

            it("complex") {
                let oldChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VPhantom<Int>(),
                ]
                let newChildren: [AnyVTree<NoMsg>] = [
                    *VPhantom<String>(),
                    *VPhantom<Float>(),
                    *VView(key: key2),
                    *VView(key: key3),
                    *VPhantom<Double>(),
                ]

                var steps = Patch<NoMsg>.Steps()
                _diffChildren(old: oldChildren, new: newChildren, steps: &steps, parentIndex: 0)

                expect(steps.count) == 3
                expect(steps[0]) == [
                    .insertChild(newChildren[1]),
                    .insertChild(newChildren[3]),
                    .insertChild(newChildren[4]),
                    .reorderChildren(Reorder(
                        removes: [(nil, 0), (key2, 0)],
                        inserts: [(key2, 2)]
                    )),
                ]
                expect(steps[1]) == [.removeChild(oldChildren[0])]
                expect(steps[2]).to(beNil())
                expect(steps[3]) == [.replace(newChildren[0])]
            }

            #if os(iOS) || os(tvOS)
            it("handlers are added/changed/removed") {

                let oldChildren: [AnyVTree<MyMsg>] = [
                    *VButton(key: key1),
                    *VButton(key: key2, handlers: [.touchDown : .msg2]),
                    *VButton(key: key3, handlers: [.valueChanged : .msg3]),
                    *VButton(title: "h1", handlers: [.touchDragExit : .msg3]),
                    *VButton(title: "h2", handlers: [.touchDragEnter : .msg4]),
                ]
                let newChildren: [AnyVTree<MyMsg>] = [
                    *VButton(key: key1, handlers: [.touchUpInside : .msg1]),    // added
                    *VButton(key: key2),                                        // removed
                    *VButton(key: key3, handlers: [.valueChanged : .msg3]),     // not changed
                    *VButton(title: "h1", handlers: [.touchDragExit : .msg4]),  // value changed
                    *VButton(title: "h2", handlers: [.touchCancel : .msg4]),    // key changed
                ]

                var steps = Patch<MyMsg>.Steps()
                _diffChildren(old: oldChildren, new: newChildren, steps: &steps, parentIndex: 0)

                expect(steps.count) == 4

                do {
                    expect(steps[0]).to(beNil())
                }
                do {
                    expect(steps[1]!.count) == 1

                    let handlers = steps[1]?[0].handlers
                    expect(handlers?.removes) == []
                    expect(handlers?.updates) == [:]
                    expect(handlers?.inserts) == [.control(.touchUpInside) : .msg1]
                }
                do {
                    expect(steps[2]?.count) == 1

                    let handlers = steps[2]?[0].handlers
                    expect(handlers?.removes) == [.control(.touchDown)]
                    expect(handlers?.updates) == [:]
                    expect(handlers?.inserts) == [:]
                }
                do {
                    expect(steps[3]).to(beNil())
                }
                do {
                    expect(steps[4]?.count) == 1

                    let handlers = steps[4]?[0].handlers
                    expect(handlers?.removes) == []
                    expect(handlers?.updates) == [.control(.touchDragExit) : .msg4]
                    expect(handlers?.inserts) == [:]
                }
                do {
                    expect(steps[5]?.count) == 1

                    let handlers = steps[5]?[0].handlers
                    expect(handlers?.removes) == [.control(.touchDragEnter)]
                    expect(handlers?.updates) == [:]
                    expect(handlers?.inserts) == [.control(.touchCancel) : .msg4]
                }
            }

            it("gestures are added/changed/removed") {

                // NOTE: Needs to be declared & reused here for equality test, which requires same callsite.
                let msg1Func = ^MyGestureMsg.msg1
                let msg2Func = ^MyGestureMsg.msg2
                let msg3Func = ^MyGestureMsg.msg3
                let msg4Func = ^MyGestureMsg.msg4

                let oldChildren: [AnyVTree<MyGestureMsg>] = [
                    *VLabel(key: key1),
                    *VLabel(key: key2, gestures: [.tap : msg2Func]),
                    *VLabel(key: key3, gestures: [.tap : msg3Func]),
                    *VLabel(text: "h1", gestures: [.tap : msg3Func]),
                    *VLabel(text: "h2", gestures: [.tap : msg4Func]),
                    ]
                let newChildren: [AnyVTree<MyGestureMsg>] = [
                    *VLabel(key: key1, gestures: [.tap : msg1Func]),    // added
                    *VLabel(key: key2),                                 // removed
                    *VLabel(key: key3, gestures: [.tap : msg3Func]),    // not changed
                    *VLabel(text: "h1", gestures: [.tap : msg4Func]),   // value changed
                    *VLabel(text: "h2", gestures: [.pan : msg4Func]),   // key changed
                ]

                var steps = Patch<MyGestureMsg>.Steps()
                _diffChildren(old: oldChildren, new: newChildren, steps: &steps, parentIndex: 0)

                expect(steps.count) == 4

                do {
                    expect(steps[0]).to(beNil())
                }
                do {
                    expect(steps[1]!.count) == 1

                    let gestures = steps[1]?[0].gestures
                    expect(gestures?.removes) == []
                    expect(gestures?.updates) == [:]
                    expect(gestures?.inserts) == [.tap : msg1Func]
                }
                do {
                    expect(steps[2]?.count) == 1

                    let gestures = steps[2]?[0].gestures
                    expect(gestures?.removes) == [.tap]
                    expect(gestures?.updates) == [:]
                    expect(gestures?.inserts) == [:]
                }
                do {
                    expect(steps[3]).to(beNil())
                }
                do {
                    expect(steps[4]?.count) == 1

                    let gestures = steps[4]?[0].gestures
                    expect(gestures?.removes) == []
                    expect(gestures?.updates) == [.tap : msg4Func]
                    expect(gestures?.inserts) == [:]
                }
                do {
                    expect(steps[5]?.count) == 1

                    let gestures = steps[5]?[0].gestures
                    expect(gestures?.removes) == [.tap]
                    expect(gestures?.updates) == [:]
                    expect(gestures?.inserts) == [.pan : msg4Func]
                }
            }

            it("gestures are added/changed/removed + AnyVTrees are mapped") {

                func msgTransform(msg: MyGestureMsg) -> MyGestureMsg2
                {
                    switch msg {
                        case let .msg1(context):
                            return .msg1(context)
                        case let .msg2(context):
                            return .msg3(context)
                        case let .msg3(context):
                            return .msg3(context)
                        case let .msg4(context):
                            return .msg4(context)
                    }
                }

                let msg1Func = ^MyGestureMsg.msg1
                let msg2Func = ^MyGestureMsg.msg2
                let msg3Func = ^MyGestureMsg.msg3
                let msg4Func = ^MyGestureMsg.msg4

                func children(isNew: Bool) -> [AnyVTree<MyGestureMsg>]
                {
                    return [
                        *VLabel(key: key1, gestures: isNew ? [.tap : msg1Func] : [:]),          // added
                        *VLabel(key: key2, gestures: isNew ? [:] : [.tap : msg2Func]),          // removed
                        *VLabel(key: key3, gestures: [.tap : msg3Func]),                        // not changed
                        *VLabel(text: "h1", gestures: [.tap : (isNew ? msg4Func : msg3Func)]),  // value changed
                        *VLabel(text: "h2", gestures: [(isNew ? .pan : .tap) : msg4Func]),      // key changed
                    ]
                }

                let oldChildren: [AnyVTree<MyGestureMsg2>] = children(isNew: false).map { $0.map(msgTransform) }
                let newChildren: [AnyVTree<MyGestureMsg2>] = children(isNew: true).map { $0.map(msgTransform) }

                var steps = Patch<MyGestureMsg2>.Steps()
                _diffChildren(old: oldChildren, new: newChildren, steps: &steps, parentIndex: 0)

                expect(steps.count) == 4

                do {
                    expect(steps[0]).to(beNil())
                }
                do {
                    expect(steps[1]!.count) == 1

                    let gestures = steps[1]?[0].gestures
                    expect(gestures?.removes) == []
                    expect(gestures?.updates) == [:]
                    // Comment-Out: funcs are mapped (composed) and no longer able to test equality
//                    expect(gestures?.inserts) == [.tap : msg1Func]
                    expect(gestures?.inserts[.tap]).notTo(beNil())
                }
                do {
                    expect(steps[2]?.count) == 1

                    let gestures = steps[2]?[0].gestures
                    expect(gestures?.removes) == [.tap]
                    expect(gestures?.updates) == [:]
                    expect(gestures?.inserts) == [:]
                }
                do {
                    expect(steps[3]).to(beNil())
                }
                do {
                    expect(steps[4]?.count) == 1

                    let gestures = steps[4]?[0].gestures
                    expect(gestures?.removes) == []
//                    expect(gestures?.updates) == [.tap : msg4Func]
                    expect(gestures?.updates[.tap]).notTo(beNil())
                    expect(gestures?.inserts) == [:]
                }
                do {
                    expect(steps[5]?.count) == 1

                    let gestures = steps[5]?[0].gestures
                    expect(gestures?.removes) == [.tap]
                    expect(gestures?.updates) == [:]
//                    expect(gestures?.inserts) == [.pan : msg4Func]
                    expect(gestures?.inserts[.tap]).to(beNil())
                    expect(gestures?.inserts[.pan]).notTo(beNil())
                }
            }
            #endif
        }

        describe("_reorder") {

            it("key1 & key2 are swapped") {
                let oldChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "div")
                ]
                let newChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key2),
                    *VView(key: key1),
                    *VLabel(text: "div")
                ]

                let (midChildren, reordered) = _reorder(old: oldChildren, new: newChildren)

                expect(midChildren.count) == 3
                expect(midChildren[0]) === newChildren[1]
                expect(midChildren[1]) === newChildren[0]
                expect(midChildren[2]) === newChildren[2]
                expect(reordered.removes) == [Reorder.Remove(key: key2, from: 1)]
                expect(reordered.inserts) == [Reorder.Insert(key: key2, to: 0)]
            }

            it("complex") {
                let oldChildren: [AnyVTree<NoMsg>] = [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VPhantom<Int>(),
                ]
                let newChildren: [AnyVTree<NoMsg>] = [
                    *VPhantom<String>(),
                    *VPhantom<Float>(),
                    *VView(key: key2),
                    *VView(key: key3),
                    *VPhantom<Double>(),
                ]

                let (midChildren, reordered) = _reorder(old: oldChildren, new: newChildren)

                expect(midChildren.count) == 6
                expect(midChildren[0]).to(beNil())
                expect(midChildren[1]) === newChildren[2]
                expect(midChildren[2]) === newChildren[0]
                expect(midChildren[3]) === newChildren[1]
                expect(midChildren[4]) === newChildren[3]
                expect(midChildren[5]) === newChildren[4]

                expect(reordered) == Reorder(
                    removes: [(nil, 0), (key2, 0)],
                    inserts: [(key2, 2)]
                )
            }
        }

        describe("_keyIndex") {

            it("keys & noKeys should be generated") {
                let children: [AnyVTree<NoMsg>] = [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "div")
                ]

                let (keys, noKeys) = _keyIndexes(children)
                expect(keys) == [ObjectIdentifier(key2) : 1, ObjectIdentifier(key1) : 0]
                expect(noKeys) == [2]
            }

        }
    }
}

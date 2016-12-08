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
                    *VButton(key: key1, handlers: [.touchUpInside : .msg1]),  // added
                    *VButton(key: key2),                                                // removed
                    *VButton(key: key3, handlers: [.valueChanged : .msg3]),   // not changed
                    *VButton(title: "h1", handlers: [.touchDragExit : .msg4]),// value changed
                    *VButton(title: "h2", handlers: [.touchCancel : .msg4]),  // key changed
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

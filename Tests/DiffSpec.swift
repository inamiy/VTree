@testable import VTree
import Quick
import Nimble

class DiffSpec: QuickSpec
{
    override func spec()
    {
        describe("diff") {

            it("no diff") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1"),
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1"),
                ])

                let patch = diff(old: tree1, new: tree2)

                expect(patch.steps).to(beEmpty())
            }

            it("property changed") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1"),
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "2"),
                ])

                let patch = diff(old: tree1, new: tree2)

                expect(patch.steps.count) == 1
                expect(patch.steps[3]) == [.props(removes: [], updates: ["text" : "2"], inserts: [:])]

                // Comment-Out: Can't write as following due to unsupported HKT
//                expect(patch.steps) == [3 : [Patch.Step.props(removes: [], updates: ["text" : "2"], inserts: [:])]]
            }

            it("child changed") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1"),
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VImageView(),
                ])

                let patch = diff(old: tree1, new: tree2)

                expect(patch.steps.count) == 1
                expect(patch.steps[3]) == [.replace(tree2.children[2])]
            }

            it("key1 & key2 are swapped") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1"),
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key2),
                    *VView(key: key1),
                    *VLabel(text: "1"),
                ])

                let patch = diff(old: tree1, new: tree2)

                expect(patch.steps.count) == 1
                expect(patch.steps[0]) == [.reorderChildren(Reorder(removes: [(key: key2, from: 1)], inserts: [(key: key2, to: 0)]))]
            }

            it("complex") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VPhantom<Int>(),
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VPhantom<String>(),
                    *VPhantom<Float>(),
                    *VView(key: key2),
                    *VView(key: key3),
                    *VPhantom<Double>(),
                ])

                let patch = diff(old: tree1, new: tree2)

                expect(patch.steps.count) == 3
                expect(patch.steps[0]) == [
                    .insertChild(tree2.children[1]),
                    .insertChild(tree2.children[3]),
                    .insertChild(tree2.children[4]),
                    .reorderChildren(Reorder(
                        removes: [(nil, 0), (key2, 0)],
                        inserts: [(key2, 2)]
                    )),
                ]
                expect(patch.steps[1]) == [.removeChild(tree1.children[0])]
                expect(patch.steps[2]).to(beNil())
                expect(patch.steps[3]) == [.replace(tree2.children[0])]
            }

        }
    }
}

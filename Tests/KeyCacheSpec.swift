@testable import VTree
import Quick
import Nimble

class KeyCacheSpec: QuickSpec
{
    override func spec()
    {
        describe("diff") {

            it("no diff") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key("1")),
                    *VView(key: key("2")),
                    *VLabel(text: "1")
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key("1")),
                    *VView(key: key("2")),
                    *VLabel(text: "1")
                ])

                let patch = diff(old: tree1, new: tree2)

                expect(patch.steps).to(beEmpty())
            }

            it("key1 & key2 are swapped") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key(1)),
                    *VView(key: key(2)),
                    *VLabel(text: "1")
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key(2)),
                    *VView(key: key(1)),
                    *VLabel(text: "1")
                ])

                let patch = diff(old: tree1, new: tree2)

                expect(patch.steps.count) == 1
                expect(patch.steps[0]) == [.reorderChildren(Reorder(removes: [(key: key(2), from: 1)], inserts: [(key: key(2), to: 0)]))]
            }

        }
    }
}

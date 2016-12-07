#if os(iOS) || os(watchOS) || os(tvOS)

@testable import VTree
import Quick
import Nimble

private typealias V<T: View> = VGeneric<T, NoMsg>

class VGenericSpec: QuickSpec
{
    override func spec()
    {
        describe("VGeneric") {

            let defaultChildren: [AnyVTree<NoMsg>] = [
                *VView(key: key1),
                *VView(key: key2),
                *VLabel(text: "1"),
            ]

            it("no diff") {
                let tree1 = V<UILabel>(props: [
                    #keyPath(UILabel.text) : "hello",
                    #keyPath(UILabel.enabled) : false
                ], children: defaultChildren)

                let tree2 = V<UILabel>(props: [
                    #keyPath(UILabel.text) : "hello",
                    #keyPath(UILabel.enabled) : false
                ], children: defaultChildren)

                let view1 = tree1.createView()

                expect(view1.text) == "hello"
                expect(view1.isEnabled) == false

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1) as! UILabel

                expect(view2) == view1  // reuse
                expect(view2.text) == "hello"
                expect(view2.isEnabled) == false
            }

            it("root property changed") {
                let tree1 = V<UILabel>(props: [
                    #keyPath(UILabel.text) : "hello",
                    #keyPath(UILabel.enabled) : false
                ], children: defaultChildren)

                let tree2 = V<UILabel>(props: [
                    #keyPath(UILabel.text) : "world",
                    #keyPath(UILabel.enabled) : true
                ], children: defaultChildren)

                let view1 = tree1.createView()

                expect(view1.text) == "hello"
                expect(view1.isEnabled) == false

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1) as! UILabel

                expect(view2) == view1  // reuse
                expect(view2.text) == "world"
                expect(view2.isEnabled) == true
            }

        }
    }
}

#endif

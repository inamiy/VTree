#if os(iOS) || os(tvOS)

@testable import VTree
import Quick
import Nimble

class ApplySpec: QuickSpec
{
    override func spec()
    {
        describe("apply") {

            let defaultChildren: [AnyVTree<NoMsg>] = [
                *VView(key: key1),
                *VView(key: key2),
                *VLabel(text: "1")
            ]

            it("no diff") {
                let tree1 = VView(children: defaultChildren)
                let tree2 = VView(children: defaultChildren)

                let view1 = tree1.createView()

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)

                expect(view2) == view1  // reuse
            }

            it("root type changed -> new view") {
                let tree1 = VView(children: defaultChildren)
                let tree2 = VImageView(children: defaultChildren)

                let view1 = tree1.createView()

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)

                expect(view2).notTo(beNil())
                expect(view2) != view1  // replaced
            }

            it("root property (value type) changed") {
                let tree1 = VView(styles: VViewStyles { $0.isHidden = false }, children: defaultChildren)
                let tree2 = VView(styles: VViewStyles { $0.isHidden = true }, children: defaultChildren)

                let view1 = tree1.createView()

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)

                expect(view2) == view1  // reuse
            }

            it("root property (value type) changed to nil") {
                let tree1 = VLabel<NoMsg>(text: "hello")
                let tree2 = VLabel<NoMsg>(text: nil)

                let view1 = tree1.createView()

                expect(view1.text) == "hello"

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1) as! Label

                expect(view2) == view1  // reuse
                expect(view2.text).to(beNil())
            }

            it("root property (reference type) changed") {
                let tree1 = VView<NoMsg>(styles: VViewStyles { $0.backgroundColor = .white })
                let tree2 = VView<NoMsg>(styles: VViewStyles { $0.backgroundColor = .black })

                let view1 = tree1.createView()

                expect(view1.backgroundColor) == .white

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)

                expect(view2) == view1      // reuse
                expect(view2?.backgroundColor) == .black
            }

            it("root property (reference type) changed to nil") {
                let tree1 = VView<NoMsg>(styles: VViewStyles { $0.backgroundColor = .white })
                let tree2 = VView<NoMsg>(styles: VViewStyles { $0.backgroundColor = nil })

                let view1 = tree1.createView()

                expect(view1.backgroundColor) == .white

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)

                expect(view2) == view1      // reuse
                expect(view2?.backgroundColor).to(beNil())
            }

            it("child type changed") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1")
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VImageView()
                ])

                let view1 = tree1.createView()
                expect(view1.subviews[2] as? ImageView).to(beNil())

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)

                expect(view2) == view1  // reuse
                expect(view1.subviews[2] as? ImageView).notTo(beNil())
            }

            it("child property changed") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1")
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "2")
                ])

                let view1 = tree1.createView()
                let label1 = view1.subviews[2] as! Label

                expect(label1.text) == "1"

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)
                let label2 = view2!.subviews[2] as! Label

                expect(view2) == view1      // reuse
                expect(label2) == label1    // reuse
                expect(label2.text) == "2"
            }

            it("child reordered") {
                let tree1 = VView<NoMsg>(children: [
                    *VView(key: key1),
                    *VView(key: key2),
                    *VLabel(text: "1")
                ])
                let tree2 = VView<NoMsg>(children: [
                    *VView(key: key2),
                    *VView(key: key1),
                    *VLabel(text: "1")
                ])

                let view1 = tree1.createView()
                let subview0 = view1.subviews[0]
                let subview1 = view1.subviews[1]

                let patch = diff(old: tree1, new: tree2)

                let view2 = apply(patch: patch, to: view1)

                expect(view2) == view1      // reuse
                expect(view2?.subviews[0]) == subview1    // reuse
                expect(view2?.subviews[1]) == subview0    // reuse
            }

        }
    }
}

#endif

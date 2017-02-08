import CoreGraphics
@testable import VTree

extension VTree
{
    /// `createView(config)` helper which ignores flexbox.
    func createTestView<Msg2: Message>(_ msgMapper: @escaping (MsgType) -> Msg2) -> ViewType
    {
        let config = ViewConfig<MsgType, Msg2>(msgMapper: msgMapper, skipsFlexbox: false)
        return self.createView(config)
    }
}

/// `_diffChildren` helper which ignores flexbox.
func testDiffChildren<Msg: Message>(old oldChildren: [AnyVTree<Msg>], new newChildren: [AnyVTree<Msg>], steps: inout Patch<Msg>.Steps, parentIndex: Int)
{
    var flexboxFrames = [Int: [CGRect]]()

    _diffChildren(
        old: oldChildren,
        new: newChildren,
        steps: &steps,
        flexboxFrames: &flexboxFrames,
        skipsFlexbox: false,
        parentIndex: 0
    )
}

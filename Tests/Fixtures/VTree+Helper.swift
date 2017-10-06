import CoreGraphics
@testable import VTree

extension VTree
{
    /// `createView(config)` helper which ignores flexbox.
    func createTestView<Msg2: Message>(_ msgMapper: @escaping (MsgType) -> Msg2) -> ViewType
    {
        return self.createView(msgMapper)
    }
}

/// `_diffChildren` helper which ignores flexbox.
func testDiffChildren<Msg>(old oldChildren: [AnyVTree<Msg>], new newChildren: [AnyVTree<Msg>], steps: inout Patch<Msg>.Steps, parentIndex: Int)
{
    var layoutDirty = LayoutDirtyReason.none

    _diffChildren(
        old: oldChildren,
        new: newChildren,
        parentIndex: 0,
        steps: &steps,
        layoutDirty: &layoutDirty
    )
}

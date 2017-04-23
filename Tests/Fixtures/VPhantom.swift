import VTree
import Flexbox

/// Phantom type for `VTree` without `Message` type (for testing).
public final class VPhantom<👻>: VTree
{
    public let key: Key?
    public let props: [String: Any] = [:]  // NOTE: `Segmentation fault: 11` if removing this line
    public let flexbox: Flexbox.Node? = nil
    public let children: [AnyVTree<NoMsg>]

    public init(
        key: Key? = nil,
        children: [AnyVTree<NoMsg>] = []
        )
    {
        self.key = key
        self.children = children
    }

    public func createView<Msg2: Message>(_ msgMapper: @escaping (NoMsg) -> Msg2) -> View
    {
        let view = View()

        for child in self.children {
            view.addSubview(child.createView(msgMapper))
        }

        return view
    }
}

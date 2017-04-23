import Flexbox

/// Virtual tree node without `PropsReflectable`.
/// This is a basic generic class that has type-unsafe `props` only,
/// and relies on KVC to create a new view.
public final class VGeneric<V: View, Msg: Message>: VTree
{
    public let key: Key?
    public let props: [String: Any]
    public let flexbox: Flexbox.Node?

    public let handlers: HandlerMapping<Msg>
    public let gestures: [GestureEvent<Msg>]
    public let children: [AnyVTree<Msg>]

    public init(
        key: Key? = nil,
        props: [String: Any] = [:],
        flexbox: Flexbox.Node? = nil,
        handlers: HandlerMapping<Msg> = [:],
        gestures: [GestureEvent<Msg>] = [],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key
        self.props = props
        self.flexbox = flexbox
        self.handlers = handlers
        self.gestures = gestures
        self.children = children
    }

    public func createView<Msg2: Message>(_ msgMapper: @escaping (Msg) -> Msg2) -> V
    {
        let view = V()
        self._setupView(view, msgMapper: msgMapper)
        return view
    }
}

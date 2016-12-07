/// Type-erased `VTree` with lazy `map` support.
/// - Note: Lazy `map` could be splitted into another enum type.
public final class AnyVTree<Msg: Message>: VTree
{
    public let key: Key?
    public let props: [String : Any]

    private let _children: [Any]
    private let _childrenTransform: (Any) -> AnyVTree<Msg>

    private let _handlers: [CocoaEvent : Any]
    private let _handlersTransform: (Any) -> Msg

    private let _createView: (@escaping (Msg) -> AnyMsg) -> View

    /// Type-unsafe raw `VTree` type for comparison.
    internal let _rawType: Any.Type

    public init<Base: VTree>(_ base: Base) where Base.MsgType == Msg
    {
        self._rawType = _rawVTreeType(of: base)

        self.key = base.key
        self.props = base.props

        self._handlers = base.handlers
        self._handlersTransform = { $0 as! Base.MsgType }

        self._children = base.children
        self._childrenTransform = { $0 as! AnyVTree<Base.MsgType> }

        self._createView = { msgMapper in
            return base.createView { msgMapper($0) }
        }
    }

    /// Private initializer for lazy `map`.
    private init<Base: VTree>(_ base: Base, transform: @escaping (Base.MsgType) -> Msg)
    {
        self._rawType = _rawVTreeType(of: base)

        self.key = base.key
        self.props = base.props

        if let base = base as? AnyVTree<Base.MsgType> {
            self._handlers = base._handlers
            self._handlersTransform = { transform(base._handlersTransform($0)) }
            self._children = base._children
            self._childrenTransform = { base._childrenTransform($0).map(transform) }
        }
        else {
            self._handlers = base.handlers
            self._handlersTransform = { transform($0 as! Base.MsgType) }
            self._children = base.children
            self._childrenTransform = { ($0 as! AnyVTree<Base.MsgType>).map(transform) }
        }

        self._createView = { msgMapper in
            return base.createView { msgMapper(transform($0)) }
        }
    }

    public var handlers: [CocoaEvent : Msg]
    {
        let transform = self._handlersTransform
        return self._handlers.map { ($0, transform($1)) }
    }

    public var children: [AnyVTree<Msg>]
    {
        let transform = self._childrenTransform
        return self._children.map { transform($0) }
    }

    public func createView<Msg2: Message>(_ msgMapper: @escaping (Msg) -> Msg2) -> View
    {
        return self._createView { AnyMsg(msgMapper($0)) }
    }

    /// Lazy `map`.
    public func map<Msg2: Message>(_ transform: @escaping (Msg) -> Msg2) -> AnyVTree<Msg2>
    {
        return AnyVTree<Msg2>(self, transform: transform)
    }
}

// MARK: Custom Operators

prefix operator *

/// Shortcut for creating `AnyVTree` from `VTree`.
public prefix func * <T: VTree, Msg: Message>(tree: T) -> AnyVTree<Msg>
    where T.MsgType == Msg
{
    if let tree = tree as? AnyVTree<Msg> {
        return tree
    }
    return AnyVTree(tree)
}

// MARK: Private

private func _rawVTreeType<T: VTree>(of tree: T) -> Any.Type
{
    if let t = tree as? AnyVTree<T.MsgType> {
        return t._rawType
    }
    return type(of: tree)
}
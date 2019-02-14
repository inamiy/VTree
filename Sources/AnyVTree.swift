import Flexbox

/// Type-erased `VTree` with lazy `map` support.
/// - Note: Lazy `map` could be splitted into another enum type.
public final class AnyVTree<Msg: Message>: VTree
{
    public let key: Key?
    public let props: [String: Any]
    public let propsKeysForMeasure: [String]
    public let flexbox: Flexbox.Node?

    private let _children: () -> [AnyVTree<Msg>]
    private let _handlers: () -> [SimpleEvent: Msg]
    private let _gestures: () -> [GestureEvent<Msg>]

    private let _createView: (@escaping (Msg) -> AnyMsg) -> View

    /// Type-unsafe raw `VTree` type for comparison.
    internal let _rawType: Any.Type

    public init<Base: VTree>(_ base: Base) where Base.MsgType == Msg
    {
        self._rawType = _rawVTreeType(of: base)

        self.key = base.key
        self.props = base.props
        self.propsKeysForMeasure = base.propsKeysForMeasure
        self.flexbox = base.flexbox

        self._handlers = { base.handlers }
        self._gestures = { base.gestures }
        self._children = { base.children }

        self._createView = base.createView
    }

    /// Private initializer for lazy `map`.
    private init<Base: VTree>(_ base: Base, transform: @escaping (Base.MsgType) -> Msg)
    {
        self._rawType = _rawVTreeType(of: base)
        self.key = base.key
        self.props = base.props
        self.propsKeysForMeasure = base.propsKeysForMeasure
        self.flexbox = base.flexbox

        self._handlers = { base.handlers.mapValues(transform) }
        self._gestures = { base.gestures.map { $0.map(transform) } }
        self._children = { base.children.map { $0.map(transform) } }

        self._createView = { msgMapper in
            return base.createView { msgMapper(transform($0)) }
        }
    }

    public var handlers: HandlerMapping<Msg>
    {
        return self._handlers()
    }

    public var gestures: [GestureEvent<Msg>]
    {
        return self._gestures()
    }

    public var children: [AnyVTree<Msg>]
    {
        return self._children()
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

    internal var _descendantCount: Int
    {
        return self.children.reduce(0) { $0 + 1 + $1._descendantCount }
    }
}

extension AnyVTree: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return "AnyVTree(\(_rawType))"
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

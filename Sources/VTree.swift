import CoreGraphics

/// Base protocol for virtual tree node.
///
/// - Note:
/// Conformance of this protocol doesn't have to be "class only",
/// but using a class is recommended for faster diff calculation.
public protocol VTree
{
    associatedtype ViewType: View
    associatedtype MsgType: Message

    /// Identity used for efficient reordering.
    var key: Key? { get }

    /// Type-unsafe property dictionary to reflect to real view via Key-Value-Coding.
    /// - Warning: `Dictionary.Value` respects to `Mirror.Child`'s value as `Any`, which may be `nil`.
    /// - Warning: Some property names e.g. `"isHidden"` is not allowed in ObjC, so use e.g. `"hidden"` instead.
    var props: [String: Any] { get }

    /// `SimpleEvent` to `Message` mapping.
    var handlers: HandlerMapping<MsgType> { get }

    /// `GestureEvent` to `Message`-function (`FuncBox`) mapping.
    var gestures: [GestureEvent<MsgType>] { get }

    /// VTree children.
    var children: [AnyVTree<MsgType>] { get }

    /// `VTree -> View` constructor.
    func createView() -> ViewType

    /// `VTree -> View` constructor with lazy `Msg` mapper.
    /// This is analogous to Elm-Native-VirtualDom's `render(node, eventNode)`.
    ///
    /// - Parameter msgMapper:
    /// A lazy mapping function that is passed via `AnyVTree.map`
    /// or just plain `id` function i.e. `{ $0 }` via `createView()`.
    func createView<Msg2: Message>(_ msgMapper: @escaping (MsgType) -> Msg2) -> ViewType
}

extension VTree
{
    // Default implementation.
    public var handlers: HandlerMapping<MsgType>
    {
        return [:]
    }

    // Default implementation.
    public var gestures: [GestureEvent<MsgType>]
    {
        return []
    }

    // Default implementation.
    public func createView() -> ViewType
    {
        return self.createView { $0 }
    }
}

import CoreGraphics
import Flexbox

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

    /// Keys in `props` that is used in `flexbox.measure`.
    /// For example, `VLabel` uses `text` and `font` to calculate layout
    /// using `flexbox.measure`.
    var propsKeysForMeasure: [String] { get }

    /// CSS Flexbox that is used in VTree to calculate flexible layout frames.
    ///
    /// - Note:
    /// `flexbox.children` and `flexbox.measure` are not required.
    ///
    /// - Note:
    /// If `props` has `"frame"` value as `CGRect`, VTree will try merging it
    /// to the `flexbox`'s `size` and `position`.
    ///
    /// - SeeAlso: https://github.com/inamiy/Flexbox
    var flexbox: Flexbox.Node? { get }

    /// `SimpleEvent` to `Message` mapping.
    var handlers: HandlerMapping<MsgType> { get }

    /// Array of `GestureEvent` that contains `Message`-function (`FuncBox`).
    var gestures: [GestureEvent<MsgType>] { get }

    /// VTree children.
    var children: [AnyVTree<MsgType>] { get }

    /// `VTree -> View` constructor with lazy `Msg` mapper.
    /// This is analogous to Elm-Native-VirtualDom's `render(node, eventNode)`.
    ///
    /// - Note:
    /// This method is mainly used for internal purpose.
    /// To create a view hierarchy from root VTree, use `VTree.createView()` instead.
    func createView<Msg2: Message>(_ msgMapper: @escaping (MsgType) -> Msg2) -> ViewType
}

// MARK: Default implementation

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
    public var propsKeysForMeasure: [String]
    {
        return []
    }

    /// Entrypoint of creating a root view from `VTree`.
    public func createView() -> ViewType
    {
        return self.createView { $0 }
    }
}

// MARK: Flexbox

extension VTree
{
    /// - Returns: `nil` if `flexbox` doesn't exist.
    internal var _flexboxTree: Flexbox.Node
    {
        /// Creates complete `Flexbox.Node`s from VTree children, even if child's flexbox is missing.
        ///
        /// - Note:
        /// VTree applies flexbox from the topmost "VTree with flexbox property"
        /// all the way down to its descendants.
        func flexboxChildren(_ vtreeChildren: [AnyVTree<MsgType>]) -> [Flexbox.Node]
        {
            return vtreeChildren.map { childTree in
                return childTree._flexboxTree
            }
        }

        return {
            return Flexbox.Node(size: $0.size, minSize: $0.minSize, maxSize: $0.maxSize, children: flexboxChildren(self.children), flexDirection: $0.flexDirection, flexWrap: $0.flexWrap, justifyContent: $0.justifyContent, alignContent: $0.alignContent, alignItems: $0.alignItems, alignSelf: $0.alignSelf, flex: $0.flex, flexGrow: $0.flexGrow, flexShrink: $0.flexShrink, flexBasis: $0.flexBasis, direction: $0.direction, overflow: $0.overflow, positionType: $0.positionType, position: $0.position, margin: $0.margin, padding: $0.padding, border: $0.border, measure: $0.measure)
        }(self._canonicalFlexbox)
    }

    /// Formal flexbox that also takes care of `props["frame"]`
    /// by converting it to `flexbox.size` and `flexbox.position`.
    ///
    /// - Returns: `nil` if `flexbox` doesn't exist.
    private var _canonicalFlexbox: Flexbox.Node
    {
        if let frame = self.props["frame"] as? CGRect, frame != .null {
            return self.flexbox.map {
                return Flexbox.Node(size: frame.size, minSize: $0.minSize, maxSize: $0.maxSize, children: $0.children, flexDirection: $0.flexDirection, flexWrap: $0.flexWrap, justifyContent: $0.justifyContent, alignContent: $0.alignContent, alignItems: $0.alignItems, alignSelf: $0.alignSelf, flex: $0.flex, flexGrow: $0.flexGrow, flexShrink: $0.flexShrink, flexBasis: $0.flexBasis, direction: $0.direction, overflow: $0.overflow, positionType: .absolute, position: Edges(left: frame.origin.x, top: frame.origin.y), margin: $0.margin, padding: $0.padding, border: $0.border, measure: $0.measure)
            }
                ?? Flexbox.Node(size: frame.size, positionType: .absolute, position: Edges(left: frame.origin.x, top: frame.origin.y))
        }
        else {
            return self.flexbox ?? Flexbox.Node()
        }
    }
}

import Flexbox

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Virtual tree node for `NSView`/`UIView`.
public final class VView<Msg: Message>: VTree, PropsReflectable
{
    public typealias PropsData = VViewPropsData

    public let key: Key?
    public let flexbox: Flexbox.Node?
    public let gestures: [GestureEvent<Msg>]
    public let children: [AnyVTree<Msg>]

    public let propsData: PropsData

    public init(
        key: Key? = nil,
        styles: VViewStyles = .emptyInit(),
        gestures: [GestureEvent<Msg>] = [],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key
        self.flexbox = styles.flexbox
        self.gestures = gestures
        self.children = children
        self.propsData = PropsData(styles: styles)
    }

    public func createView<Msg2: Message>(_ msgMapper: @escaping (Msg) -> Msg2) -> View
    {
        let view = View()
        self._setupView(view, msgMapper: msgMapper)
        return view
    }
}

// MARK: Styles

public protocol HasViewStyles
{
    var viewStyles: VViewStyles { get set }
}

extension HasViewStyles
{
    public var frame: CGRect
    {
        get {
            return self.viewStyles.frame
        }
        set {
            self.viewStyles.frame = newValue
        }
    }

    public var backgroundColor: Color?
    {
        get {
            return self.viewStyles.backgroundColor
        }
        set {
            self.viewStyles.backgroundColor = newValue
        }
    }

    public var alpha: CGFloat
    {
        get {
            return self.viewStyles.alpha
        }
        set {
            self.viewStyles.alpha = newValue
        }
    }

    public var isHidden: Bool
    {
        get {
            return self.viewStyles.isHidden
        }
        set {
            self.viewStyles.isHidden = newValue
        }
    }

    public var cornerRadius: CGFloat
    {
        get {
            return self.viewStyles.cornerRadius
        }
        set {
            self.viewStyles.cornerRadius = newValue
        }
    }

    public var flexbox: Flexbox.Node?
    {
        get {
            return self.viewStyles.flexbox
        }
        set {
            self.viewStyles.flexbox = newValue
        }
    }
}

public struct VViewStyles
{
    public var frame: CGRect = .null
    public var backgroundColor: Color? = nil
    public var alpha: CGFloat = 1
    public var isHidden: Bool = false

    public var cornerRadius: CGFloat = 0

    public var flexbox: Flexbox.Node? = nil
}

extension VViewStyles: InoutMutable
{
    public static func emptyInit() -> VViewStyles
    {
        return self.init()
    }
}

// MARK: PropsData

public struct VViewPropsData
{
    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool

    fileprivate let vtree_cornerRadius: CGFloat
}

extension VViewPropsData
{
    public init(styles: VViewStyles)
    {
        self.frame = styles.frame
        self.backgroundColor = styles.backgroundColor
        self.alpha = styles.alpha
        self.hidden = styles.isHidden
        self.vtree_cornerRadius = styles.cornerRadius
    }
}

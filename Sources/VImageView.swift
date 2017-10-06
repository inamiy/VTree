import Flexbox

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Virtual tree node for `NSImageView`/`UIImageView`.
public final class VImageView<Msg: Message>: VTree, PropsReflectable
{
    public typealias PropsData = VImageViewPropsData

    public let key: Key?
    public let flexbox: Flexbox.Node?
    public let gestures: [GestureEvent<Msg>]
    public let children: [AnyVTree<Msg>]

    public let propsData: PropsData

    public init(
        key: Key? = nil,
        image: Image? = nil,
        styles: VImageViewStyles = .emptyInit(),
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

    public func createView<Msg2: Message>(_ msgMapper: @escaping (Msg) -> Msg2) -> ImageView
    {
        let view = ImageView()
        self._setupView(view, msgMapper: msgMapper)
        return view
    }
}

// MARK: Styles

public struct VImageViewStyles: HasViewStyles
{
    public var viewStyles = VViewStyles()

    public var image: Image? = nil
}

extension VImageViewStyles: InoutMutable
{
    public static func emptyInit() -> VImageViewStyles
    {
        return self.init()
    }
}

// MARK: PropsData

public struct VImageViewPropsData
{
    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool

    fileprivate let vtree_cornerRadius: CGFloat

    fileprivate let image: Image?
}

extension VImageViewPropsData
{
    fileprivate init(styles: VImageViewStyles)
    {
        self.frame = styles.frame
        self.backgroundColor = styles.backgroundColor
        self.alpha = styles.alpha
        self.hidden = styles.isHidden
        self.vtree_cornerRadius = styles.cornerRadius

        self.image = styles.image
    }
}

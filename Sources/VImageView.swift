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
        frame: CGRect = .null,
        backgroundColor: Color? = nil,
        alpha: CGFloat = 1,
        isHidden: Bool = false,
        image: Image? = nil,
        flexbox: Flexbox.Node? = nil,
        gestures: [GestureEvent<Msg>] = [],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key
        self.flexbox = flexbox
        self.gestures = gestures
        self.children = children
        self.propsData = PropsData(frame: frame, backgroundColor: backgroundColor, alpha: alpha, hidden: isHidden, image: image)
    }

    public func createView<Msg2: Message>(_ config: ViewConfig<Msg, Msg2>) -> ImageView
    {
        let view = ImageView()

        self._setupView(view, config: config)

        return view
    }
}

// MARK: PropsData

public struct VImageViewPropsData
{
    public typealias ViewType = ImageView

    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool

    fileprivate let image: Image?
}

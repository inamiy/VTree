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
        frame: CGRect = .null,
        backgroundColor: Color? = nil,
        alpha: CGFloat = 1,
        isHidden: Bool = false,
        flexbox: Flexbox.Node? = nil,
        gestures: [GestureEvent<Msg>] = [],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key
        self.flexbox = flexbox
        self.gestures = gestures
        self.children = children
        self.propsData = PropsData(frame: frame, backgroundColor: backgroundColor, alpha: alpha, hidden: isHidden)
    }

    public func createView<Msg2: Message>(_ config: ViewConfig<Msg, Msg2>) -> View
    {
        let view = View()

        self._setupView(view, config: config)

        return view
    }
}

// MARK: PropsData

public struct VViewPropsData
{
    public typealias ViewType = View

    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool
}

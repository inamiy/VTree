#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Virtual tree node for `NSTextField`/`UILabel`.
public final class VLabel<Msg: Message>: VTree, PropsReflectable
{
    public typealias PropsData = VLabelPropsData

    public let key: Key?
    public let gestures: [GestureEvent<Msg>]
    public let children: [AnyVTree<Msg>]

    public let propsData: PropsData

    public init(
        key: Key? = nil,
        frame: CGRect = .zero,
        backgroundColor: Color? = nil,
        alpha: CGFloat = 1,
        isHidden: Bool = false,
        font: Font? = nil,
        text: String? = nil,
        textAlignment: NSTextAlignment = .left,
        gestures: [GestureEvent<Msg>] = [],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key
        self.gestures = gestures
        self.children = children
        self.propsData = PropsData(frame: frame, backgroundColor: backgroundColor, alpha: alpha, hidden: isHidden, font: font, text: text, textAlignment: textAlignment.rawValue)
    }

    public func createView<Msg2: Message>(_ msgMapper: @escaping (Msg) -> Msg2) -> Label
    {
        let view = Label()

        self._setupView(view, msgMapper: msgMapper)

        return view
    }
}

// MARK: PropsData

public struct VLabelPropsData
{
    public typealias ViewType = Label

    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool

    fileprivate let font: Font?
    fileprivate let text: String?
    fileprivate let textAlignment: NSTextAlignment.RawValue
}

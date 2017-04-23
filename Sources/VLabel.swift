import Flexbox

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// View for `measure` calculation.
private let _calcView = Label()

/// Virtual tree node for `NSTextField`/`UILabel`.
public final class VLabel<Msg: Message>: VTree, PropsReflectable
{
    public typealias PropsData = VLabelPropsData

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
        cornerRadius: CGFloat = 0,
        text: String? = nil,
        textColor: Color? = nil,
        textAlignment: NSTextAlignment = .left,
        font: Font? = nil,
        numberOfLines: Int = 0,
        flexbox: Flexbox.Node? = nil,
        gestures: [GestureEvent<Msg>] = [],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key

        let measure: ((CGSize) -> CGSize) = { maxSize in
            objc_sync_enter(_calcView)
            defer { objc_sync_exit(_calcView) }

            _calcView.text = text
            _calcView.font = font

            #if os(iOS) || os(tvOS)
            _calcView.numberOfLines = numberOfLines
            #elseif os(macOS)
            _calcView.maximumNumberOfLines = numberOfLines
            #endif

            let calcSize = _calcView.sizeThatFits(maxSize)
            return calcSize
        }

        self.flexbox = flexbox.map {
            return Flexbox.Node(size: $0.size, minSize: $0.minSize, maxSize: $0.maxSize, children: $0.children, flexDirection: $0.flexDirection, flexWrap: $0.flexWrap, justifyContent: $0.justifyContent, alignContent: $0.alignContent, alignItems: $0.alignItems, alignSelf: $0.alignSelf, flex: $0.flex, flexGrow: $0.flexGrow, flexShrink: $0.flexShrink, flexBasis: $0.flexBasis, direction: $0.direction, overflow: $0.overflow, positionType: $0.positionType, position: $0.position, margin: $0.margin, padding: $0.padding, border: $0.border, measure: measure)
        }

        self.gestures = gestures
        self.children = children
        self.propsData = PropsData(frame: frame, backgroundColor: backgroundColor, alpha: alpha, hidden: isHidden, vtree_cornerRadius: cornerRadius, text: text, textColor: textColor, textAlignment: textAlignment.rawValue, font: font, vtree_numberOfLines: numberOfLines)
    }

    public var propsKeysForMeasure: [String]
    {
        return ["font", "text", "vtree_numberOfLines"]
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

    fileprivate let vtree_cornerRadius: CGFloat

    fileprivate let text: String?
    fileprivate let textColor: Color?
    fileprivate let textAlignment: NSTextAlignment.RawValue
    fileprivate let font: Font?

    fileprivate let vtree_numberOfLines: Int
}

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

    public let propsData: PropsData

    public init(
        key: Key? = nil,
        text: Text? = nil,
        styles: VLabelStyles = .emptyInit(),
        gestures: [GestureEvent<Msg>] = []
        )
    {
        self.key = key

        let font = styles.font
        let numberOfLines = styles.numberOfLines

        let measure: ((CGSize) -> CGSize) = { maxSize in
            objc_sync_enter(_calcView)
            defer { objc_sync_exit(_calcView) }

            switch text {
                case let .text(text)?:
                    _calcView.attributedText = nil
                    _calcView.text = text
                case let .attributedText(attributedText)?:
                    _calcView.text = nil
                    _calcView.attributedText = attributedText
                case .none:
                    _calcView.text = nil
                    _calcView.attributedText = nil
            }
            _calcView.font = font

            #if os(iOS) || os(tvOS)
            _calcView.numberOfLines = numberOfLines
            #elseif os(macOS)
            _calcView.maximumNumberOfLines = numberOfLines
            #endif

            let calcSize = _calcView.sizeThatFits(maxSize)
            return calcSize
        }

        self.flexbox = (styles.flexbox ?? Flexbox.Node()).map {
            var flexbox = $0
            return flexbox.mutate {
                $0.measure = measure
            }
        }

        self.gestures = gestures
        self.propsData = VLabelPropsData(text: text, styles: styles)
    }

    public var propsKeysForMeasure: [String]
    {
        return ["text", "attributedText", "font", "vtree_numberOfLines"]
    }

    public var children: [AnyVTree<Msg>]
    {
        return []
    }

    public func createView<Msg2: Message>(_ msgMapper: @escaping (Msg) -> Msg2) -> Label
    {
        let view = Label()
        self._setupView(view, msgMapper: msgMapper)
        return view
    }
}

// MARK: Styles

public struct VLabelStyles: HasViewStyles
{
    public var viewStyles = VViewStyles()

    public var textColor: Color? = nil
    public var textAlignment: NSTextAlignment = .left
    public var font: Font? = nil

    public var numberOfLines: Int = 0
}

extension VLabelStyles: InoutMutable
{
    public static func emptyInit() -> VLabelStyles
    {
        return self.init()
    }
}

// MARK: PropsData

public struct VLabelPropsData
{
    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool

    fileprivate let vtree_cornerRadius: CGFloat

    fileprivate let text: String?
    fileprivate let attributedText: NSAttributedString?
    fileprivate let textColor: Color?
    fileprivate let textAlignment: NSTextAlignment.RawValue
    fileprivate let font: Font?

    fileprivate let vtree_numberOfLines: Int
}

extension VLabelPropsData
{
    fileprivate init(text: Text?, styles: VLabelStyles)
    {
        self.frame = styles.frame
        self.backgroundColor = styles.backgroundColor
        self.alpha = styles.alpha
        self.hidden = styles.isHidden
        self.vtree_cornerRadius = styles.cornerRadius

        switch text {
            case let .text(text)?:
                self.attributedText = nil
                self.text = text
            case let .attributedText(attributedText)?:
                self.text = nil
                self.attributedText = attributedText
            case .none:
                self.text = nil
                self.attributedText = nil
        }
        self.textColor = styles.textColor
        self.textAlignment = styles.textAlignment.rawValue
        self.font = styles.font
        self.vtree_numberOfLines = styles.numberOfLines
    }
}

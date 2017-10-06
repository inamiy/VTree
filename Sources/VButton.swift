import Flexbox

#if os(iOS) || os(tvOS)
import UIKit

/// View for `measure` calculation.
private let _calcView = UIButton()

/// Virtual tree node for `UIButton`.
public final class VButton<Msg: Message>: VTree, PropsReflectable
{
    public typealias PropsData = VButtonPropsData

    public let key: Key?
    public let flexbox: Flexbox.Node?
    //public let gestures: [GestureEvent<Msg>]  // Comment-Out: Use `handlers` instead.

    public let propsData: PropsData

    private let _handlers: [UIControlEvents: Msg]

    public init(
        key: Key? = nil,
        title: Text? = nil,
        styles: VButtonStyles = .emptyInit(),
        handlers: [UIControlEvents: Msg] = [:]
        )
    {
        self.key = key

        let measure: ((CGSize) -> CGSize) = { maxSize in
            objc_sync_enter(_calcView)
            defer { objc_sync_exit(_calcView) }

            switch title {
                case let .text(text)?:
                    _calcView.setAttributedTitle(nil, for: .normal)
                    _calcView.setTitle(text, for: .normal)
                case let .attributedText(attributedText)?:
                    _calcView.setTitle(nil, for: .normal)
                    _calcView.setAttributedTitle(attributedText, for: .normal)
                case .none:
                    _calcView.setTitle(nil, for: .normal)
                    _calcView.setAttributedTitle(nil, for: .normal)
            }
            _calcView.titleLabel?.font = styles.font
            _calcView.titleLabel?.numberOfLines = styles.numberOfLines

            let calcSize = _calcView.sizeThatFits(maxSize)
            return calcSize
        }

        self.flexbox = (styles.flexbox ?? Flexbox.Node()).map {
            var flexbox = $0
            return flexbox.mutate {
                $0.measure = measure
            }
        }

        self._handlers = handlers
        self.propsData = PropsData(title: title, styles: styles)
    }

    public var propsKeysForMeasure: [String]
    {
        return ["vtree_title", "vtree_attributedTitle", "vtree_font", "vtree_numberOfLines"]
    }

    public var handlers: HandlerMapping<Msg>
    {
        return self._handlers.map { (.control($0), $1) }
    }

    public var children: [AnyVTree<Msg>]
    {
        return []
    }

    public func createView<Msg2: Message>(_ msgMapper: @escaping (Msg) -> Msg2) -> Button
    {
        let view = Button()
        self._setupView(view, msgMapper: msgMapper)

        for (event, msg) in self._handlers {
            let msg2 = msgMapper(msg)
            view.vtree.addHandler(for: event) { _ in
                Messenger.shared.send(AnyMsg(msg2))
            }
        }

        return view
    }
}

// MARK: Styles

public struct VButtonStyles: HasViewStyles
{
    public var viewStyles = VViewStyles()

    public var titleColor: Color? = nil
    public var font: Font? = nil
    public var numberOfLines: Int = 0
}

extension VButtonStyles: InoutMutable
{
    public static func emptyInit() -> VButtonStyles
    {
        return self.init()
    }
}

// MARK: PropsData

public struct VButtonPropsData
{
    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool

    fileprivate let vtree_cornerRadius: CGFloat

    fileprivate let vtree_title: String?
    fileprivate let vtree_attributedTitle: NSAttributedString?
    fileprivate let vtree_titleColor: Color?
    fileprivate let vtree_font: Font?

    fileprivate let vtree_numberOfLines: Int
}

extension VButtonPropsData
{
    fileprivate init(title: Text?, styles: VButtonStyles)
    {
        self.frame = styles.frame
        self.backgroundColor = styles.backgroundColor
        self.alpha = styles.alpha
        self.hidden = styles.isHidden
        self.vtree_cornerRadius = styles.cornerRadius

        switch title {
            case let .text(text)?:
                self.vtree_attributedTitle = nil
                self.vtree_title = text
            case let .attributedText(attributedText)?:
                self.vtree_title = nil
                self.vtree_attributedTitle = attributedText
            case .none:
                self.vtree_title = nil
                self.vtree_attributedTitle = nil
        }
        self.vtree_titleColor = styles.titleColor
        self.vtree_font = styles.font
        self.vtree_numberOfLines = styles.numberOfLines
    }
}

#endif

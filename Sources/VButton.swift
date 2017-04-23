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
    public let children: [AnyVTree<Msg>]

    public let propsData: PropsData

    private let _handlers: [UIControlEvents: Msg]

    public init(
        key: Key? = nil,
        frame: CGRect = .null,
        backgroundColor: Color? = nil,
        alpha: CGFloat = 1,
        isHidden: Bool = false,
        cornerRadius: CGFloat = 0,
        title: String? = nil,
        titleColor: Color? = nil,
        font: Font? = nil,
        numberOfLines: Int = 0,
        flexbox: Flexbox.Node? = nil,
        handlers: [UIControlEvents: Msg] = [:],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key

        let measure: ((CGSize) -> CGSize) = { maxSize in
            objc_sync_enter(_calcView)
            defer { objc_sync_exit(_calcView) }

            _calcView.setTitle(title, for: .normal)
            _calcView.titleLabel?.font = font
            _calcView.titleLabel?.numberOfLines = numberOfLines

            let calcSize = _calcView.sizeThatFits(maxSize)
            return calcSize
        }

        self.flexbox = flexbox.map {
            return Flexbox.Node(size: $0.size, minSize: $0.minSize, maxSize: $0.maxSize, children: $0.children, flexDirection: $0.flexDirection, flexWrap: $0.flexWrap, justifyContent: $0.justifyContent, alignContent: $0.alignContent, alignItems: $0.alignItems, alignSelf: $0.alignSelf, flex: $0.flex, flexGrow: $0.flexGrow, flexShrink: $0.flexShrink, flexBasis: $0.flexBasis, direction: $0.direction, overflow: $0.overflow, positionType: $0.positionType, position: $0.position, margin: $0.margin, padding: $0.padding, border: $0.border, measure: measure)
        }

        self._handlers = handlers
        self.children = children
        self.propsData = PropsData(frame: frame, backgroundColor: backgroundColor, alpha: alpha, hidden: isHidden, vtree_cornerRadius: cornerRadius, vtree_title: title, vtree_titleColor: titleColor, vtree_font: font, vtree_numberOfLines: numberOfLines)
    }

    public var propsKeysForMeasure: [String]
    {
        return ["vtree_title", "vtree_font", "vtree_numberOfLines"]
    }

    public var handlers: HandlerMapping<Msg>
    {
        return self._handlers.map { (.control($0), $1) }
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

// MARK: PropsData

public struct VButtonPropsData
{
    public typealias ViewType = Button

    fileprivate let frame: CGRect
    fileprivate let backgroundColor: Color?
    fileprivate let alpha: CGFloat
    fileprivate let hidden: Bool

    fileprivate let vtree_cornerRadius: CGFloat

    fileprivate let vtree_title: String?
    fileprivate let vtree_titleColor: Color?
    fileprivate let vtree_font: Font?
    fileprivate let vtree_numberOfLines: Int
}

#endif

#if os(iOS) || os(tvOS)
import UIKit

/// Virtual tree node for `UIButton`.
public final class VButton<Msg: Message>: VTree, PropsReflectable
{
    public typealias PropsData = VButtonPropsData

    public let key: Key?
    //public let gestures: GestureMapping<Msg>  // Comment-Out: Use `handlers` instead.
    public let children: [AnyVTree<Msg>]

    public let propsData: PropsData

    private let _handlers: [UIControlEvents: Msg]

    public init(
        key: Key? = nil,
        frame: CGRect = .zero,
        backgroundColor: Color? = nil,
        alpha: CGFloat = 1,
        isHidden: Bool = false,
        title: String? = nil,
        titleColor: Color? = nil,
        titleFont: Font? = nil,
        handlers: [UIControlEvents: Msg] = [:],
        children: [AnyVTree<Msg>] = []
        )
    {
        self.key = key
        self._handlers = handlers
        self.children = children
        self.propsData = PropsData(frame: frame, backgroundColor: backgroundColor, alpha: alpha, hidden: isHidden, title: title, titleColor: titleColor, titleFont: titleFont)
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

    fileprivate let title: String?
    fileprivate let titleColor: Color?
    fileprivate let titleFont: Font?
}

#endif

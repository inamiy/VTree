import Foundation

extension VTree
{
    /// Common view setup logic using KVC.
    internal func _setupView<Msg2: Message>(_ view: ViewType, msgMapper: @escaping (MsgType) -> Msg2)
    {
        for prop in self.props {
            view.setValue(_toOptionalAny(prop.value), forKey: prop.key)
        }

        for child in self.children {
            view.addSubview(child.createView(msgMapper))
        }

        for (event, msgFunc) in self.gestures {
            (view as View).vtree.addGesture(for: event) { gesture in
                let context = GestureContext(location: gesture.location(in: gesture.view), state: gesture.state)
                let msg = msgFunc.impl(context)
                let msg2 = msgMapper(msg)
                Messenger.shared.send(AnyMsg(msg2))
            }
        }
    }
}

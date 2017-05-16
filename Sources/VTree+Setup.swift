import Foundation

extension VTree
{
    /// Common view setup logic using KVC.
    internal func _setupView<Msg2: Message>(_ view: ViewType, msgMapper: @escaping (MsgType) -> Msg2)
    {
        view.isVTreeView = true

        // Set `nil` first
        let props = self.props.map { ($0.key, _toOptionalAny($0.value)) }
        for prop in props.sorted(by: { $1.1 != nil }) {
            view.setValue(prop.1, forKey: prop.0)
        }

        for child in self.children {
            view.addSubview(child.createView(msgMapper))
        }

        for gesture in self.gestures {
            (view as View).vtree.addGesture(for: gesture) { msg in
                let msg2 = msgMapper(msg)
                Messenger.shared.send(AnyMsg(msg2))
            }
        }
    }
}

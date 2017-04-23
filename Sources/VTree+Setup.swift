import Foundation

extension VTree
{
    /// Common view setup logic using KVC.
    internal func _setupView<Msg2: Message>(_ view: ViewType, msgMapper: @escaping (MsgType) -> Msg2)
    {
        view.isVTreeView = true

        for prop in self.props {
            view.setValue(_toOptionalAny(prop.value), forKey: prop.key)
        }

        for child in self.children {
            view.addSubview(child.createView(msgMapper))
        }

        let frames = calculateFlexbox(self._flexboxTree)
        applyFlexbox(frames: frames, to: view)

        for gesture in self.gestures {
            (view as View).vtree.addGesture(for: gesture) { msg in
                let msg2 = msgMapper(msg)
                Messenger.shared.send(AnyMsg(msg2))
            }
        }
    }
}

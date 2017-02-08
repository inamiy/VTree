import Foundation

extension VTree
{
    /// Common view setup logic using KVC.
    internal func _setupView<Msg2: Message>(_ view: ViewType, config: ViewConfig<MsgType, Msg2>)
    {
        view.isVTreeView = true

        for prop in self.props {
            view.setValue(_toOptionalAny(prop.value), forKey: prop.key)
        }

        if let flexboxTree = self._flexboxTree {
            let config2 = ViewConfig(msgMapper: config._msgMapper, skipsFlexbox: true)

            for child in self.children {
                view.addSubview(child.createView(config2))
            }

            let frames = calculateFlexbox(flexboxTree)
            applyFlexbox(frames: frames, to: view)
        }
        else {
            for child in self.children {
                view.addSubview(child.createView(config))
            }
        }

        for gesture in self.gestures {
            (view as View).vtree.addGesture(for: gesture) { msg in
                let msg2 = config._msgMapper(msg)
                Messenger.shared.send(AnyMsg(msg2))
            }
        }
    }
}

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
    }
}

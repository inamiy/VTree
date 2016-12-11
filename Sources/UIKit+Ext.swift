#if os(iOS) || os(tvOS)

import UIKit

extension UIView
{
    internal func replaceSubview(_ oldView: UIView, with newView: UIView)
    {
        self.insertSubview(newView, aboveSubview: oldView)
        oldView.removeFromSuperview()
    }
}

// MARK: UIControl + SimpleEvent.control

extension VTreePrefix where Base: UIControl
{
    internal typealias ControlTargets = [UIControlEvents : CocoaTarget<UIControl>]

    /// `CocoaTarget` storage that has a reference type.
    internal var controlTargets: MutableBox<ControlTargets>
    {
        return self.associatedValue { _ in MutableBox<ControlTargets>([:]) }
    }

    internal func addHandler(for controlEvents: UIControlEvents, handler: @escaping (UIControl) -> ())
    {
        if self.controlTargets.value[controlEvents] == nil {
            self.controlTargets.value[controlEvents] = CocoaTarget<UIControl>(handler) { $0 as! UIControl }
        }

        let target = self.controlTargets.value[controlEvents]!

        self.base.addTarget(target, action: #selector(target.sendNext), for: controlEvents)
    }

    internal func removeHandler(for controlEvents: UIControlEvents)
    {
        if let target = self.controlTargets.value[controlEvents] {
            self.base.removeTarget(target, action: #selector(target.sendNext), for: controlEvents)

            self.controlTargets.value[controlEvents] = nil
        }
    }
}

// MARK: UIControlEvents + Hashable

extension UIControlEvents: Hashable
{
    public var hashValue: Int
    {
        return Int(self.rawValue)
    }
}

#endif

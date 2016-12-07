#if os(iOS) || os(watchOS) || os(tvOS)

import UIKit

extension UIView
{
    internal func replaceSubview(_ oldView: UIView, with newView: UIView)
    {
        self.insertSubview(newView, aboveSubview: oldView)
        oldView.removeFromSuperview()
    }
}

extension VTreePrefix where Base: NSObject
{
    internal typealias CocoaTargets = [CocoaEvent : CocoaTarget<UIControl>]

    /// `CocoaTarget<UIControl>` storage that has a reference type.
    internal var cocoaTargets: MutableBox<CocoaTargets>
    {
        return self.associatedValue { _ in MutableBox<CocoaTargets>([:]) }
    }

    internal func cocoaTarget(for cocoaEvent: CocoaEvent) -> CocoaTarget<UIControl>?
    {
        return self.cocoaTargets.value[cocoaEvent]
    }
}

extension VTreePrefix where Base: UIControl
{
    internal func addHandler(for controlEvents: UIControlEvents, handler: @escaping (UIControl) -> ())
    {
        let cocoaEvent = CocoaEvent.control(controlEvents)

        if self.cocoaTarget(for: cocoaEvent) == nil {
            self.cocoaTargets.value[cocoaEvent] = CocoaTarget<UIControl>(handler) { $0 as! UIControl }
        }

        let target = self.cocoaTarget(for: cocoaEvent)!

        self.base.addTarget(target, action: #selector(target.sendNext), for: controlEvents)
    }

    internal func removeHandler(for controlEvents: UIControlEvents)
    {
        let cocoaEvent = CocoaEvent.control(controlEvents)

        if let target = self.cocoaTarget(for: cocoaEvent) {
            self.base.removeTarget(target, action: #selector(target.sendNext), for: controlEvents)

            self.cocoaTargets.value[cocoaEvent] = nil
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

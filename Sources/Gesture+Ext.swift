#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

// MARK: UIView + GestureEvent

extension VTreePrefix where Base: View
{
    internal typealias GestureTargets = [GestureEvent: CocoaTarget<GestureRecognizer>]

    /// `CocoaTarget` storage that has a reference type.
    internal var gestureTargets: MutableBox<GestureTargets>
    {
        return self.associatedValue { _ in MutableBox<GestureTargets>([:]) }
    }

    internal func addGesture(for gestureEvent: GestureEvent, handler: @escaping (GestureRecognizer) -> ())
    {
        guard self.gestureTargets.value[gestureEvent] == nil else {
            return
        }

        let target = CocoaTarget<GestureRecognizer>(handler) { $0 as! GestureRecognizer }
        self.gestureTargets.value[gestureEvent] = target

        let gesture = gestureEvent._gestureType.init()

        #if os(iOS) || os(tvOS)
        gesture.addTarget(target, action: #selector(target.sendNext))
        #elseif os(macOS)
        gesture.target = target
        gesture.action = #selector(target.sendNext)
        #endif

        self.base.addGestureRecognizer(gesture)
    }

    internal func removeGesture(for gestureEvent: GestureEvent)
    {
        #if os(iOS) || os(tvOS)
        guard let gestures = self.base.gestureRecognizers else { return }
        #elseif os(macOS)
        let gestures = self.base.gestureRecognizers
        #endif

        if self.gestureTargets.value[gestureEvent] != nil {
            for gesture in gestures where type(of: gesture) == gestureEvent._gestureType {
                self.base.removeGestureRecognizer(gesture)
                break
            }
            self.gestureTargets.value[gestureEvent] = nil
        }
    }
}

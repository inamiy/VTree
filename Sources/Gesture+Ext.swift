#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

// MARK: UIView + GestureEvent

extension VTreePrefix where Base: View
{
    internal typealias Gestures = [GestureEvent<AnyMsg>: GestureRecognizer]
    internal typealias GestureTargets = [GestureEvent<AnyMsg>: CocoaTarget<GestureRecognizer>]

    /// Indexed gestures storage.
    internal var gestures: MutableBox<Gestures>
    {
        return self.associatedValue { _ in MutableBox<Gestures>([:]) }
    }

    /// `CocoaTarget` storage that has a reference type.
    internal var gestureTargets: MutableBox<GestureTargets>
    {
        return self.associatedValue { _ in MutableBox<GestureTargets>([:]) }
    }

    internal func addGesture<Msg: Message>(for gestureEvent: GestureEvent<Msg>, handler: @escaping (Msg) -> ())
    {
        let anyMsgGestureEvent = gestureEvent.map(AnyMsg.init)

        guard self.gestureTargets.value[anyMsgGestureEvent] == nil else {
            return
        }

        let gestureHandler: (GestureRecognizer) -> () = { gesture in
            let msg = gestureEvent._createMessage(from: gesture)
            handler(msg)
        }

        let target = CocoaTarget<GestureRecognizer>(gestureHandler) { $0 as! GestureRecognizer }

        let gesture = gestureEvent._createGesture()

        #if os(iOS) || os(tvOS)
        gesture.addTarget(target, action: #selector(target.sendNext))
        #elseif os(macOS)
        gesture.target = target
        gesture.action = #selector(target.sendNext)
        #endif

        self.base.addGestureRecognizer(gesture)
        self.gestures.value[anyMsgGestureEvent] = gesture
        self.gestureTargets.value[anyMsgGestureEvent] = target
    }

    internal func removeGesture<Msg: Message>(for gestureEvent: GestureEvent<Msg>)
    {
        let anyMsgGestureEvent = gestureEvent.map(AnyMsg.init)

        if let gesture = self.gestures.value[anyMsgGestureEvent] {
            self.base.removeGestureRecognizer(gesture)
            self.gestures.value[anyMsgGestureEvent] = nil
            self.gestureTargets.value[anyMsgGestureEvent] = nil
        }
    }
}

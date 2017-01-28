#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Cocoa gesture event type that `VTree` interpets to make event-handler diffs.
public enum GestureEvent<Msg>
{
    #if os(iOS)

    case tap(FuncBox<GestureContext, Msg>)
    case pan(FuncBox<PanGestureContext, Msg>)
    case longPress(FuncBox<GestureContext, Msg>)
    case swipe(FuncBox<GestureContext, Msg>)
    case pinch(FuncBox<PinchGestureContext, Msg>)
    case rotation(FuncBox<RotationGestureContext, Msg>)

    public func map<Msg2: Message>(_ transform: @escaping (Msg) -> Msg2) -> GestureEvent<Msg2>
    {
        switch self {
            case let .tap(f):
                return .tap(f.map(transform))
            case let .pan(f):
                return .pan(f.map(transform))
            case let .longPress(f):
                return .longPress(f.map(transform))
            case let .swipe(f):
                return .swipe(f.map(transform))
            case let .pinch(f):
                return .pinch(f.map(transform))
            case let .rotation(f):
                return .rotation(f.map(transform))
        }
    }

    internal func _createGesture() -> GestureRecognizer
    {
        switch self {
            case .tap:
                return UITapGestureRecognizer()
            case .pan:
                return UIPanGestureRecognizer()
            case .longPress:
                return UILongPressGestureRecognizer()
            case .swipe:
                return UISwipeGestureRecognizer()
            case .pinch:
                return UIPinchGestureRecognizer()
            case .rotation:
                return UIRotationGestureRecognizer()
        }
    }

    internal func _createMessage(from gesture: GestureRecognizer) -> Msg
    {
        switch self {
            case let .tap(f):
                let gesture = gesture as! UITapGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .pan(f):
                let gesture = gesture as! UIPanGestureRecognizer
                let context = PanGestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view),
                    velocity: gesture.velocity(in: gesture.view)
                )
                return f.impl(context)

            case let .longPress(f):
                let gesture = gesture as! UILongPressGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .swipe(f):
                let gesture = gesture as! UISwipeGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .pinch(f):
                let gesture = gesture as! UIPinchGestureRecognizer
                let context = PinchGestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view),
                    scale: gesture.scale,
                    velocity: gesture.velocity
                )
                return f.impl(context)

            case let .rotation(f):
                let gesture = gesture as! UIRotationGestureRecognizer
                let context = RotationGestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view),
                    rotation: gesture.rotation,
                    velocity: gesture.velocity
                )
                return f.impl(context)
        }
    }

    #elseif os(tvOS)

    case tap(FuncBox<GestureContext, Msg>)
    case pan(FuncBox<PanGestureContext, Msg>)
    case longPress(FuncBox<GestureContext, Msg>)
    case swipe(FuncBox<GestureContext, Msg>)

    public func map<Msg2: Message>(_ transform: @escaping (Msg) -> Msg2) -> GestureEvent<Msg2>
    {
        switch self {
            case let .tap(f):
                return .tap(f.map(transform))
            case let .pan(f):
                return .pan(f.map(transform))
            case let .longPress(f):
                return .longPress(f.map(transform))
            case let .swipe(f):
                return .swipe(f.map(transform))
        }
    }

    internal func _createGesture() -> GestureRecognizer
    {
        switch self {
            case .tap:
                return UITapGestureRecognizer()
            case .pan:
                return UIPanGestureRecognizer()
            case .longPress:
                return UILongPressGestureRecognizer()
            case .swipe:
                return UISwipeGestureRecognizer()
        }
    }

    internal func _createMessage(from gesture: GestureRecognizer) -> Msg
    {
        switch self {
            case let .tap(f):
                let gesture = gesture as! UITapGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .pan(f):
                let gesture = gesture as! UIPanGestureRecognizer
                let context = PanGestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view),
                    velocity: gesture.velocity(in: gesture.view)
                )
                return f.impl(context)

            case let .longPress(f):
                let gesture = gesture as! UILongPressGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .swipe(f):
                let gesture = gesture as! UISwipeGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)
        }
    }

    #elseif os(macOS)

    case click(FuncBox<GestureContext, Msg>)
    case pan(FuncBox<PanGestureContext, Msg>)
    case press(FuncBox<GestureContext, Msg>)
    case rotation(FuncBox<GestureContext, Msg>)         // TODO: Use custom context.
    case magnification(FuncBox<GestureContext, Msg>)    // TODO: Use custom context.

    public func map<Msg2: Message>(_ transform: @escaping (Msg) -> Msg2) -> GestureEvent<Msg2>
    {
        switch self {
            case let .click(f):
                return .click(f.map(transform))
            case let .pan(f):
                return .pan(f.map(transform))
            case let .press(f):
                return .press(f.map(transform))
            case let .rotation(f):
                return .rotation(f.map(transform))
            case let .magnification(f):
                return .magnification(f.map(transform))
        }
    }

    internal func _createGesture() -> GestureRecognizer
    {
        switch self {
            case .click:
                return NSClickGestureRecognizer()
            case .pan:
                return NSPanGestureRecognizer()
            case .press:
                return NSPressGestureRecognizer()
            case .rotation:
                return NSRotationGestureRecognizer()
            case .magnification:
                return NSMagnificationGestureRecognizer()
        }
    }

    internal func _createMessage(from gesture: GestureRecognizer) -> Msg
    {
        switch self {
            case let .click(f):
                let gesture = gesture as! NSClickGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .pan(f):
                let gesture = gesture as! NSPanGestureRecognizer
                let context = PanGestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view),
                    velocity: gesture.velocity(in: gesture.view)
                )
                return f.impl(context)

            case let .press(f):
                let gesture = gesture as! NSPressGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .rotation(f):
                let gesture = gesture as! NSRotationGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)

            case let .magnification(f):
                let gesture = gesture as! NSMagnificationGestureRecognizer
                let context = GestureContext(
                    state: gesture.state,
                    location: gesture.location(in: gesture.view)
                )
                return f.impl(context)
        }
    }

    #endif
}

extension GestureEvent: Equatable
{
    public static func == (lhs: GestureEvent<Msg>, rhs: GestureEvent<Msg>) -> Bool
    {
        #if os(iOS)

        switch (lhs, rhs) {
            case let (.tap(l), .tap(r)) where l == r:
                return true
            case let (.pan(l), .pan(r)) where l == r:
                return true
            case let (.longPress(l), .longPress(r)) where l == r:
                return true
            case let (.swipe(l), .swipe(r)) where l == r:
                return true
            case let (.pinch(l), .pinch(r)) where l == r:
                return true
            case let (.rotation(l), .rotation(r)) where l == r:
                return true
            default:
                return false
        }

        #elseif os(tvOS)

        switch (lhs, rhs) {
            case let (.tap(l), .tap(r)) where l == r:
                return true
            case let (.pan(l), .pan(r)) where l == r:
                return true
            case let (.longPress(l), .longPress(r)) where l == r:
                return true
            case let (.swipe(l), .swipe(r)) where l == r:
                return true
            default:
                return false
        }

        #elseif os(macOS)

        switch (lhs, rhs) {
            case let (.click(l), .click(r)) where l == r:
                return true
            case let (.pan(l), .pan(r)) where l == r:
                return true
            case let (.press(l), .press(r)) where l == r:
                return true
            case let (.rotation(l), .rotation(r)) where l == r:
                return true
            case let (.magnification(l), .magnification(r)) where l == r:
                return true
            default:
                return false
        }

        #endif
    }
}

extension GestureEvent: Hashable
{
    public var hashValue: Int
    {
        #if os(iOS)

        switch self {
            case let .tap(f):
                return _hashValue(x: f, y: 0)
            case let .pan(f):
                return _hashValue(x: f, y: 1)
            case let .longPress(f):
                return _hashValue(x: f, y: 2)
            case let .swipe(f):
                return _hashValue(x: f, y: 3)
            case let .pinch(f):
                return _hashValue(x: f, y: 4)
            case let .rotation(f):
                return _hashValue(x: f, y: 5)
        }

        #elseif os(tvOS)

        switch self {
            case let .tap(f):
                return _hashValue(x: f, y: 0)
            case let .pan(f):
                return _hashValue(x: f, y: 1)
            case let .longPress(f):
                return _hashValue(x: f, y: 2)
            case let .swipe(f):
                return _hashValue(x: f, y: 3)
        }

        #elseif os(macOS)

        switch self {
            case let .click(f):
                return _hashValue(x: f, y: 0)
            case let .pan(f):
                return _hashValue(x: f, y: 1)
            case let .press(f):
                return _hashValue(x: f, y: 2)
            case let .rotation(f):
                return _hashValue(x: f, y: 3)
            case let .magnification(f):
                return _hashValue(x: f, y: 4)
        }

        #endif
    }
}

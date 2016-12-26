#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Cocoa gesture event type that `VTree` interpets to make event-handler diffs.
public enum GestureEvent: String
{
    #if os(iOS)

    case tap
    case pan
    case longPress
    case swipe
    case pinch
    case rotation

    internal var _gestureType: GestureRecognizer.Type
    {
        switch self {
            case .tap:
                return UITapGestureRecognizer.self
            case .pan:
                return UIPanGestureRecognizer.self
            case .longPress:
                return UILongPressGestureRecognizer.self
            case .swipe:
                return UISwipeGestureRecognizer.self
            case .pinch:
                return UIPinchGestureRecognizer.self
            case .rotation:
                return UIRotationGestureRecognizer.self
        }
    }

    #elseif os(tvOS)

    case tap
    case pan
    case longPress
    case swipe

    internal var _gestureType: GestureRecognizer.Type
    {
        switch self {
        case .tap:
            return UITapGestureRecognizer.self
        case .pan:
            return UIPanGestureRecognizer.self
        case .longPress:
            return UILongPressGestureRecognizer.self
        case .swipe:
            return UISwipeGestureRecognizer.self
        }
    }

    #elseif os(macOS)

    case click
    case pan
    case press
    case rotation
    case magnification

    internal var _gestureType: GestureRecognizer.Type
    {
        switch self {
            case .click:
                return NSClickGestureRecognizer.self
            case .pan:
                return NSPanGestureRecognizer.self
            case .press:
                return NSPressGestureRecognizer.self
            case .rotation:
                return NSRotationGestureRecognizer.self
            case .magnification:
                return NSMagnificationGestureRecognizer.self
        }
    }
    #endif
}

/// Gesture handler mapping with handler type as `(GestureContext) -> Msg`.
public typealias GestureMapping<Msg: Message> = [GestureEvent: FuncBox<GestureContext, Msg>]

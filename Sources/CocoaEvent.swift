#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Simple Cocoa event source type that `VTree` interpets to make event-handler diffs.
public enum CocoaEvent: Hashable
{
    #if os(iOS) || os(tvOS)
    case control(UIControlEvents)
    #else
//    case targetAction  // TODO: for NSButton
    #endif

    public static func == (lhs: CocoaEvent, rhs: CocoaEvent) -> Bool
    {
        #if os(iOS) || os(tvOS)
            if case let (.control(l), .control(r)) = (lhs, rhs), l == r {
                return true
            }
        #endif

        return false
    }

    public var hashValue: Int
    {
        #if os(iOS) || os(tvOS)
            if case let .control(controlEvents) = self {
                return Int(controlEvents.rawValue)
            }
        #endif

        return 1 << 31
    }
}

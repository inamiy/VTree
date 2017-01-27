#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

// MARK: MessageContext

/// Protocol that represents `enum Msg`'s "associated values (arguments)",
/// interacting with https://github.com/krzysztofzablocki/Sourcery.
/// - SeeAlso: Templates/Message.stencil
public protocol MessageContext: RawRepresentable
{
    init?(rawValue: [Any])
    var rawValue: [Any] { get }
}

// MARK: GestureContext

/// Gesture arguments to interact with Sourcery, e.g. `case tap(GestureContext)`.
public struct GestureContext
{
    public let location: CGPoint
    public let state: GestureState
}

extension GestureContext: MessageContext
{
    public init?(rawValue: [Any])
    {
        guard rawValue.count == 2,
            let point = rawValue[0] as? CGPoint,
            let state = rawValue[1] as? GestureState else
        {
            return nil
        }

        self = GestureContext(location: point, state: state)
    }

    public var rawValue: [Any]
    {
        return [location, state]
    }
}

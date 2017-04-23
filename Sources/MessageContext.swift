#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

// MARK: MessageContext

/// Protocol that represents `enum Msg`'s "associated values (arguments)",
/// interacting with https://github.com/krzysztofzablocki/Sourcery.
/// - SeeAlso: Templates/Message.stencil
public protocol MessageContext
{
    init?(rawArguments: [Any])
    var rawArguments: [Any] { get }
}

// MARK: GestureContext

/// Common (tap, longPress, swipe) gesture arguments to interact with Sourcery, e.g. `case tap(GestureContext)`.
public struct GestureContext: _AutoMessageContext
{
    public let state: GestureState
    public let location: CGPoint
}

/// Pan gesture arguments to interact with Sourcery.
public struct PanGestureContext: _AutoMessageContext
{
    public let state: GestureState
    public let location: CGPoint
    public let velocity: CGPoint
}

/// Pinch gesture arguments to interact with Sourcery.
public struct PinchGestureContext: _AutoMessageContext
{
    public let state: GestureState
    public let location: CGPoint
    public let scale: CGFloat
    public let velocity: CGFloat
}

/// Rotation gesture arguments to interact with Sourcery.
public struct RotationGestureContext: _AutoMessageContext
{
    public let state: GestureState
    public let location: CGPoint
    public let rotation: CGFloat
    public let velocity: CGFloat
}

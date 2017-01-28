// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif



extension GestureContext: MessageContext
{
    public init?(rawValue: [Any])
    {
        guard rawValue.count == 2 else { return nil }

        guard let state = rawValue[1 - 1] as? GestureState else { return nil }

        guard let location = rawValue[2 - 1] as? CGPoint else { return nil }

        self = GestureContext(state: state, location: location)
    }

    public var rawValue: [Any]
    {
        return [state, location]
    }
}

extension PanGestureContext: MessageContext
{
    public init?(rawValue: [Any])
    {
        guard rawValue.count == 3 else { return nil }

        guard let state = rawValue[1 - 1] as? GestureState else { return nil }

        guard let location = rawValue[2 - 1] as? CGPoint else { return nil }

        guard let velocity = rawValue[3 - 1] as? CGPoint else { return nil }

        self = PanGestureContext(state: state, location: location, velocity: velocity)
    }

    public var rawValue: [Any]
    {
        return [state, location, velocity]
    }
}

extension PinchGestureContext: MessageContext
{
    public init?(rawValue: [Any])
    {
        guard rawValue.count == 4 else { return nil }

        guard let state = rawValue[1 - 1] as? GestureState else { return nil }

        guard let location = rawValue[2 - 1] as? CGPoint else { return nil }

        guard let scale = rawValue[3 - 1] as? CGFloat else { return nil }

        guard let velocity = rawValue[4 - 1] as? CGFloat else { return nil }

        self = PinchGestureContext(state: state, location: location, scale: scale, velocity: velocity)
    }

    public var rawValue: [Any]
    {
        return [state, location, scale, velocity]
    }
}

extension RotationGestureContext: MessageContext
{
    public init?(rawValue: [Any])
    {
        guard rawValue.count == 4 else { return nil }

        guard let state = rawValue[1 - 1] as? GestureState else { return nil }

        guard let location = rawValue[2 - 1] as? CGPoint else { return nil }

        guard let rotation = rawValue[3 - 1] as? CGFloat else { return nil }

        guard let velocity = rawValue[4 - 1] as? CGFloat else { return nil }

        self = RotationGestureContext(state: state, location: location, rotation: rotation, velocity: velocity)
    }

    public var rawValue: [Any]
    {
        return [state, location, rotation, velocity]
    }
}


import UIKit
import VTree

/// Complex `Message` type that has associated values.
/// - Important: See `VTree.Message` comment documentation for more detail.
public enum Msg: AutoMessage
{
    case increment
    case decrement
    case tap(GestureContext)
    case pan(PanGestureContext)
    case longPress(GestureContext)
    case swipe(GestureContext)
    case pinch(PinchGestureContext)
    case rotation(RotationGestureContext)

    case dummy(DummyContext)
}

/// Custom `MessageContext` that is recognizable in Sourcery.
public struct DummyContext: AutoMessageContext {}

import VTree

/// Simple `Message` type (String RawRepresentable).
public enum Msg: AutoMessage
{
    case increment
    case decrement
}

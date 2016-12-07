/// Minimal 1:1 event-emitter, and a replacement for `NotificationCenter`.
public final class Messenger
{
    /// - Note: `var`, since `handler` needs to be set lazily.
    public var handler: (AnyMsg) -> () = { _ in }

    public init() {}

    public func send(_ msg: AnyMsg)
    {
        self.handler(msg)
    }

    /// Singleton used in `VTree` event handling.
    public static let shared = Messenger()
}

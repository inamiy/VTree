/// Message protocol that `VTree` generates from Cocoa's events,
/// then it dipatches corresponding **`AnyMsg`** via `Messenger`.
///
/// - Note:
/// Implementing `Message` will be a tedious work,
/// so use https://github.com/krzysztofzablocki/Sourcery
/// to assist code-generation for **`enum Msg` with associated values**.
///
/// 1. Conform to `AutoMessage` protocol (instead of `Message`).
/// 2. Run below script to automatically generate `extension Msg: Message`.
///
/// ```
/// enum Msg: AutoMessage { case tap(GestureContext), longPress(GestureContext), ... }
///
/// // Run script:
/// // $ <VTree-root>/Scripts/generate-message.sh <source-dir> <code-generated-dir>
/// ```
public protocol Message: RawRepresentable
{
    init?(rawValue: RawMessage)
    var rawValue: RawMessage { get }
}

// MARK: RawMessage

public struct RawMessage
{
    public let funcName: String
    public let arguments: [Any]

    public init(funcName: String, arguments: [Any])
    {
        self.funcName = funcName
        self.arguments = arguments
    }
}

// MARK: NoMsg

/// "No message" type that conforms to `Message` protocol.
public enum NoMsg: Message
{
    public init?(rawValue: RawMessage)
    {
        return nil
    }

    public var rawValue: RawMessage
    {
        return RawMessage(funcName: "", arguments: [])
    }
}

// MARK: AnyMsg

/// Type-erased `Message`.
public struct AnyMsg: Message
{
    private let _rawMessage: RawMessage

    public init<Msg: Message>(_ base: Msg)
    {
        self._rawMessage = base.rawValue
    }

    public init?(rawValue: RawMessage)
    {
        return nil
    }

    public var rawValue: RawMessage
    {
        return self._rawMessage
    }
}

extension Message
{
    /// Converts from `AnyMsg`.
    public init?(_ anyMsg: AnyMsg)
    {
        self.init(rawValue: anyMsg.rawValue)
    }
}

/// Message protocol that `VTree` generates from Cocoa's events,
/// then it dispatches corresponding **`AnyMsg`** via `Messenger`.
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
public protocol Message: MessageContext
{
    init?(rawMessage: RawMessage)
    var rawMessage: RawMessage { get }
}

extension Message
{
    public init?(rawArguments: [Any])
    {
        var rawArguments = rawArguments
        guard let funcName = rawArguments.popLast() as? String else { return nil }

        self.init(rawMessage: RawMessage(funcName: funcName, arguments: rawArguments))
    }

    public var rawArguments: [Any]
    {
        var arguments = self.rawMessage.arguments
        arguments.append(self.rawMessage.funcName)
        return arguments
    }
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
    public init?(rawMessage: RawMessage)
    {
        return nil
    }

    public var rawMessage: RawMessage
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
        self._rawMessage = base.rawMessage
    }

    public init?(rawMessage: RawMessage)
    {
        return nil
    }

    public var rawMessage: RawMessage
    {
        return self._rawMessage
    }
}

extension Message
{
    /// Converts from `AnyMsg`.
    public init?(_ anyMsg: AnyMsg)
    {
        self.init(rawMessage: anyMsg.rawMessage)
    }
}

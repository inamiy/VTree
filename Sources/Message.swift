/// Message protocol that `VTree` generates from `CocoaEvent`,
/// then it dipatches corresponding **`AnyMsg`** via `Messenger`.
///
/// - Note:
/// This protocol needs to work like "RawStringRepresentable"
/// because concrete `Message` type is not determined at framework compile time,
/// and only string-based messaging is possible.
///
/// - Note:
/// To conform your `Message` enum to this protocol, make sure to add `String` as `RawValue`, i.e.
/// ```
/// enum MyMsg: String, Message { case ... }
/// ```
public protocol Message: Hashable, RawRepresentable
{
    init?(rawValue: String)
    var rawValue: String { get }
}

extension Message
{
    public init?(_ anyMsg: AnyMsg)
    {
        self.init(rawValue: anyMsg.rawValue)
    }
}

// MARK: NoMsg

/// "No message" type that conforms to `Message` protocol.
public enum NoMsg: Message
{
    public init?(rawValue: String)
    {
        return nil
    }

    public var rawValue: String
    {
        return ""
    }

    public static func == (lhs: NoMsg, rhs: NoMsg) -> Bool
    {
        return false
    }

    public var hashValue: Int
    {
        return 0
    }
}

// MARK: AnyMsg

/// Type-erased `Message`.
public struct AnyMsg: Message
{
    private let _rawString: String
    private let _hashValue: Int

    public init<Msg: Message>(_ base: Msg)
    {
        self._rawString = base.rawValue
        self._hashValue = base.hashValue
    }

    public init?(rawValue: String)
    {
        return nil
    }

    public var rawValue: String
    {
        return self._rawString
    }

    public static func == (lhs: AnyMsg, rhs: AnyMsg) -> Bool
    {
        return lhs._hashValue == rhs._hashValue
    }

    public var hashValue: Int
    {
        return self._hashValue
    }
}

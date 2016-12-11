/// Message protocol that `VTree` generates from Cocoa's events,
/// then it dipatches corresponding **`AnyMsg`** via `Messenger`.
///
/// - Note:
/// This protocol needs to work like "RawStringRepresentable"
/// because concrete `Message` type is not determined at framework compile time,
/// and only string-based messaging is possible.
///
/// - Note:
/// To conform your `enum Msg` to this protocol, make sure to add `String` as `RawValue`, i.e.:
///
/// ```
/// enum MyMsg: String, Message { case increment, decrement, ... }
/// ```
///
/// However, if `enum Msg` needs to interact with `VTree`'s complex messages
/// e.g. `GestureEvent` that requires **associated values**,
/// Swift's automatic `RawRepresentable` is NOT possible.
///
/// ```
/// // ERROR: String as RawRepresentable.RawValue is NOT possible!
/// enum Msg: String, Message { case tap(GestureContext), longPress(GestureContext), ... }
/// ```
///
/// In such case, we can either implement `RawRepresentable` by hand (hard work!),
/// or use template-metaprogramming e.g. https://github.com/krzysztofzablocki/Sourcery
/// to assist code-generation.
///
/// 1. Add `/// sourcery: VTreeMessage` annotation
/// 2. Run below script to automatically generate `extension Msg: Message`.
///
/// ```
/// /// sourcery: VTreeMessage
/// enum Msg: { case tap(GestureContext), longPress(GestureContext), ... }
///
/// // Run script:
/// // $ <VTree-root>/Scripts/generate-message.sh <source-dir> <code-generated-dir>
/// ```
public protocol Message: RawStringRepresentable, Equatable
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

    // Default implementation.
    public static func == (l: Self, r: Self) -> Bool
    {
        return l.rawValue == r.rawValue
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
}

// MARK: AnyMsg

/// Type-erased `Message`.
public struct AnyMsg: Message
{
    private let _rawString: String

    public init<Msg: Message>(_ base: Msg)
    {
        self._rawString = base.rawValue
    }

    public init?(rawValue: String)
    {
        return nil
    }

    public var rawValue: String
    {
        return self._rawString
    }
}

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Unsafe separator for fast String message decoding/encoding.
private let _separator = "__^__"

// MARK: MessageContext

/// Protocol to convert `enum Msg`'s "associated values (arguments)" to `String`.
///
/// - Note:
/// `RawStringRepresentable` must be implemented with format:
/// `rawValue = "<argument1><sep><argument2><sep><argument3><sep>..."`.
/// See `GestureContext` for example.
///
/// - Note: This protocol interacts with Sourcery (template-metaprogramming).
public protocol MessageContext: RawStringRepresentable {}

extension MessageContext
{
    /// String-separator used to construct String message.
    ///
    /// - Note:
    /// This should be used for any `MessageContext` to implement
    /// its `init?(rawValue: String)` and `var rawValue: String`
    /// with the format: `rawValue = "<argument1><sep><argument2><sep><argument3><sep>..."`
    public static var separator: String
    {
        return _separator
    }

    /// Fully qualified String message with given `messageName` as prefix,
    /// i.e. `rawMessage = "<messageName><sep><argument1><sep><argument2><sep><argument3><sep>..."`.
    public func rawMessage(_ messageName: String) -> String
    {
        return "\(messageName)\(_separator)\(self.rawValue)"
    }
}

// MARK: GestureContext

/// Gesture arguments to interact with "enum Msg", e.g. `case tap(GestureContext)`.
/// - Note: This protocol interacts with Sourcery (template-metaprogramming).
public struct GestureContext
{
    public let location: CGPoint
    public let state: GestureState
}

extension GestureContext: MessageContext
{
    public init?(rawValue: String)
    {
        let components = rawValue.components(separatedBy: GestureContext.separator)
        guard components.count == 3,
            let x = Double(components[0]),
            let y = Double(components[1]),
            let state = Int(components[2]).flatMap(GestureState.init) else
        {
            return nil
        }

        let location = CGPoint(x: x, y: y)
        self = GestureContext(location: location, state: state)
    }

    public var rawValue: String
    {
        let sep = GestureContext.separator
        return "\(location.x)\(sep)\(location.y)\(sep)\(state.rawValue)"
    }
}

// Generated using Sourcery 0.4.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import VTree

extension Msg: Message
{
    public init?(rawValue: String)
    {
        switch rawValue {

            case "increment":
                self = .increment

            case "decrement":
                self = .decrement

            // .tap(GestureContext)
            case _ where rawValue.hasPrefix("tap\(GestureContext.separator)"):
                let count = "tap\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .tap(context)
                }
                else {
                    return nil
                }

            // .pan(GestureContext)
            case _ where rawValue.hasPrefix("pan\(GestureContext.separator)"):
                let count = "pan\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .pan(context)
                }
                else {
                    return nil
                }

            // .dummy(DummyContext)
            case _ where rawValue.hasPrefix("dummy\(DummyContext.separator)"):
                let count = "dummy\(DummyContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = DummyContext(rawValue: contextValue) {
                    self = .dummy(context)
                }
                else {
                    return nil
                }

            default:
                return nil
        }
    }

    public var rawValue: String
    {
        switch self {

            case .increment:
                return "increment"

            case .decrement:
                return "decrement"

            case let .tap(context):
                return context.rawMessage("tap")

            case let .pan(context):
                return context.rawMessage("pan")

            case let .dummy(context):
                return context.rawMessage("dummy")

        }
    }
}


// Generated using Sourcery 0.4.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import VTree

extension Msg: Message
{
    public init?(rawValue: RawMessage)
    {
        switch rawValue.funcName {

            case "increment":
                self = .increment

            case "decrement":
                self = .decrement

            // .tap(GestureContext)
            case "tap":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .tap(context)
                }
                else {
                    return nil
                }

            // .pan(GestureContext)
            case "pan":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .pan(context)
                }
                else {
                    return nil
                }

            // .dummy(DummyContext)
            case "dummy":
                let arguments = rawValue.arguments
                if let context = DummyContext(rawValue: arguments) {
                    self = .dummy(context)
                }
                else {
                    return nil
                }

            default:
                return nil
        }
    }

    public var rawValue: RawMessage
    {
        switch self {

            case .increment:
                return RawMessage(funcName: "increment", arguments: [])

            case .decrement:
                return RawMessage(funcName: "decrement", arguments: [])

            case let .tap(context):
                return RawMessage(funcName: "tap", arguments: context.rawValue)

            case let .pan(context):
                return RawMessage(funcName: "pan", arguments: context.rawValue)

            case let .dummy(context):
                return RawMessage(funcName: "dummy", arguments: context.rawValue)

        }
    }
}


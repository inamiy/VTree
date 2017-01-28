// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import VTree

extension MyGestureMsg: Message
{
    public init?(rawValue: RawMessage)
    {
        switch rawValue.funcName {

            // .msg1(GestureContext)
            case "msg1":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg1(context)
                }
                else {
                    return nil
                }

            // .msg2(GestureContext)
            case "msg2":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg2(context)
                }
                else {
                    return nil
                }

            // .msg3(GestureContext)
            case "msg3":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg3(context)
                }
                else {
                    return nil
                }

            // .msg4(GestureContext)
            case "msg4":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg4(context)
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

            case let .msg1(context):
                return RawMessage(funcName: "msg1", arguments: context.rawValue)

            case let .msg2(context):
                return RawMessage(funcName: "msg2", arguments: context.rawValue)

            case let .msg3(context):
                return RawMessage(funcName: "msg3", arguments: context.rawValue)

            case let .msg4(context):
                return RawMessage(funcName: "msg4", arguments: context.rawValue)

        }
    }
}

extension MyGestureMsg2: Message
{
    public init?(rawValue: RawMessage)
    {
        switch rawValue.funcName {

            // .msg1(GestureContext)
            case "msg1":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg1(context)
                }
                else {
                    return nil
                }

            // .msg2(GestureContext)
            case "msg2":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg2(context)
                }
                else {
                    return nil
                }

            // .msg3(GestureContext)
            case "msg3":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg3(context)
                }
                else {
                    return nil
                }

            // .msg4(GestureContext)
            case "msg4":
                let arguments = rawValue.arguments
                if let context = GestureContext(rawValue: arguments) {
                    self = .msg4(context)
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

            case let .msg1(context):
                return RawMessage(funcName: "msg1", arguments: context.rawValue)

            case let .msg2(context):
                return RawMessage(funcName: "msg2", arguments: context.rawValue)

            case let .msg3(context):
                return RawMessage(funcName: "msg3", arguments: context.rawValue)

            case let .msg4(context):
                return RawMessage(funcName: "msg4", arguments: context.rawValue)

        }
    }
}

extension MyMsg: Message
{
    public init?(rawValue: RawMessage)
    {
        switch rawValue.funcName {

            case "msg1":
                self = .msg1

            case "msg2":
                self = .msg2

            case "msg3":
                self = .msg3

            case "msg4":
                self = .msg4

            default:
                return nil
        }
    }

    public var rawValue: RawMessage
    {
        switch self {

            case .msg1:
                return RawMessage(funcName: "msg1", arguments: [])

            case .msg2:
                return RawMessage(funcName: "msg2", arguments: [])

            case .msg3:
                return RawMessage(funcName: "msg3", arguments: [])

            case .msg4:
                return RawMessage(funcName: "msg4", arguments: [])

        }
    }
}

extension MyMsg2: Message
{
    public init?(rawValue: RawMessage)
    {
        switch rawValue.funcName {

            case "test1":
                self = .test1

            case "test2":
                self = .test2

            default:
                return nil
        }
    }

    public var rawValue: RawMessage
    {
        switch self {

            case .test1:
                return RawMessage(funcName: "test1", arguments: [])

            case .test2:
                return RawMessage(funcName: "test2", arguments: [])

        }
    }
}


// Generated using Sourcery 0.4.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import VTree

extension MyGestureMsg: Message
{
    public init?(rawValue: String)
    {
        switch rawValue {

            // .msg1(GestureContext)
            case _ where rawValue.hasPrefix("msg1\(GestureContext.separator)"):
                let count = "msg1\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg1(context)
                }
                else {
                    return nil
                }

            // .msg2(GestureContext)
            case _ where rawValue.hasPrefix("msg2\(GestureContext.separator)"):
                let count = "msg2\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg2(context)
                }
                else {
                    return nil
                }

            // .msg3(GestureContext)
            case _ where rawValue.hasPrefix("msg3\(GestureContext.separator)"):
                let count = "msg3\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg3(context)
                }
                else {
                    return nil
                }

            // .msg4(GestureContext)
            case _ where rawValue.hasPrefix("msg4\(GestureContext.separator)"):
                let count = "msg4\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg4(context)
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

            case let .msg1(context):
                return context.rawMessage("msg1")

            case let .msg2(context):
                return context.rawMessage("msg2")

            case let .msg3(context):
                return context.rawMessage("msg3")

            case let .msg4(context):
                return context.rawMessage("msg4")

        }
    }
}

extension MyGestureMsg2: Message
{
    public init?(rawValue: String)
    {
        switch rawValue {

            // .msg1(GestureContext)
            case _ where rawValue.hasPrefix("msg1\(GestureContext.separator)"):
                let count = "msg1\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg1(context)
                }
                else {
                    return nil
                }

            // .msg2(GestureContext)
            case _ where rawValue.hasPrefix("msg2\(GestureContext.separator)"):
                let count = "msg2\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg2(context)
                }
                else {
                    return nil
                }

            // .msg3(GestureContext)
            case _ where rawValue.hasPrefix("msg3\(GestureContext.separator)"):
                let count = "msg3\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg3(context)
                }
                else {
                    return nil
                }

            // .msg4(GestureContext)
            case _ where rawValue.hasPrefix("msg4\(GestureContext.separator)"):
                let count = "msg4\(GestureContext.separator)".characters.count
                let fromIndex = rawValue.index(rawValue.startIndex, offsetBy: count)
                let contextValue = rawValue.substring(from: fromIndex)
                if let context = GestureContext(rawValue: contextValue) {
                    self = .msg4(context)
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

            case let .msg1(context):
                return context.rawMessage("msg1")

            case let .msg2(context):
                return context.rawMessage("msg2")

            case let .msg3(context):
                return context.rawMessage("msg3")

            case let .msg4(context):
                return context.rawMessage("msg4")

        }
    }
}


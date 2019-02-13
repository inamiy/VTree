// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import VTree
extension DebugMsg: Message
{
    public init?(rawMessage: RawMessage)
    {
        switch rawMessage.funcName {
            // .original(Msg)
            case "original":
                let arguments = rawMessage.arguments
                if let context = Msg(rawArguments: arguments) {
                    self = .original(context)
                }
                else {
                    return nil
                }
            // .slider(PanGestureContext)
            case "slider":
                let arguments = rawMessage.arguments
                if let context = PanGestureContext(rawArguments: arguments) {
                    self = .slider(context)
                }
                else {
                    return nil
                }
            default:
                return nil
        }
    }

    public var rawMessage: RawMessage
    {
        switch self {
            case let .original(context):
                return RawMessage(funcName: "original", arguments: context.rawArguments)
            case let .slider(context):
                return RawMessage(funcName: "slider", arguments: context.rawArguments)
        }
    }
}

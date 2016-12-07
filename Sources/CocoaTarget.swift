import Foundation

// From ReactiveCocoa:
// - https://github.com/ReactiveCocoa/ReactiveCocoa/blob/d3309162bfdbc10e1e79b770934b33e21d7af9b5/ReactiveCocoa/CocoaTarget.swift

/// A target that accepts action messages.
internal final class CocoaTarget<Value>: NSObject
{
    private let action: (Value) -> ()
    private let transform: (Any?) -> Value

    internal init(_ action: @escaping (Value) -> (), transform: @escaping (Any?) -> Value)
    {
        self.action = action
        self.transform = transform
    }

    @objc
    internal func sendNext(_ receiver: Any?)
    {
        action(transform(receiver))
    }
}

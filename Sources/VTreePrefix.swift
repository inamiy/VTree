import Foundation

// From ReactiveCocoa:
// - https://github.com/ReactiveCocoa/ReactiveSwift/blob/e13f2a57f4a8288e3284ca37a5b41c429d04c636/Sources/Reactive.swift
// - https://github.com/ReactiveCocoa/ReactiveCocoa/blob/d3309162bfdbc10e1e79b770934b33e21d7af9b5/ReactiveCocoa/NSObject%2BAssociation.swift

// MARK: VTreePrefix

/// Protocol that adds `.vtree` prefix to the extension methods for namespace-safety.
internal protocol VTreePrefixProvider: class {}

extension VTreePrefixProvider
{
    // Default implementation.
    internal var vtree: VTreePrefix<Self>
    {
        return VTreePrefix(self)
    }
}

/// `Base` proxy used in `VTreePrefixProvider`.
internal struct VTreePrefix<Base>
{
    internal let base: Base

    fileprivate init(_ base: Base)
    {
        self.base = base
    }
}

// MARK: VTreePrefix + NSObject

extension NSObject: VTreePrefixProvider {}

extension VTreePrefix where Base: NSObject
{
    /// Retrieve the associated value for the specified key. If the value does not
    /// exist, `initial` would be called and the returned value would be
    /// associated subsequently.
    ///
    /// - parameters:
    ///   - key: An optional key to differentiate different values.
    ///   - initial: The action that supples an initial value.
    ///
    /// - returns:
    ///   The associated value for the specified key.
    internal func associatedValue<T>(forKey key: StaticString = #function, initial: (Base) -> T) -> T
    {
        var value = objc_getAssociatedObject(self.base, key.utf8Start) as! T?
        if value == nil {
            value = initial(self.base)
            objc_setAssociatedObject(self.base, key.utf8Start, value, .OBJC_ASSOCIATION_RETAIN)
        }
        return value!
    }
}

/// Function wrapper that is `Equatable`.
///
/// - Note:
/// Passing around raw func/closure causes different result on `_peekFunc`,
/// especially when it is stored in some collection types.
/// To safely perform `_peekFunc`, it is necessary to wrap func by `struct` or `class`.
public final class FuncBox<T, U>
{
    internal let impl: (T) -> U
    fileprivate let addresses: [(Int, Int)]

    public init(_ impl: @escaping (T) -> U)
    {
        self.impl = impl

        let (fp, ctx) = _peekFunc(impl)
        self.addresses = [(fp, ctx)]
    }

    /// Functor map.
    public func map<U2>(_ transform: @escaping (U) -> U2) -> FuncBox<T, U2>
    {
        // Comment-Out: Don't create closure here!
//        return FuncBox<T, U2> { transform(self.impl($0)) }

        return FuncBox<T, U2>(self, transform)
    }

    /// Left-to-right composition.
    public func compose<V>(_ other: FuncBox<U, V>) -> FuncBox<T, V>
    {
        // Comment-Out: Don't create closure here!
//        return FuncBox<T, V> { other.impl(self.impl($0)) }

        return FuncBox<T, V>(self, other)
    }

    // MARK: Private

    /// Functor map.
    private init<X>(_ f: FuncBox<T, X>, _ transform: @escaping (X) -> U)
    {
        self.impl = { transform(f.impl($0)) }

        var addresses = f.addresses
        addresses.append(_peekFunc(transform))
        self.addresses = addresses
    }

    /// Left-to-right composition.
    private init<X>(_ f: FuncBox<T, X>, _ g: FuncBox<X, U>)
    {
        self.impl = { g.impl(f.impl($0)) }

        var addresses = f.addresses
        addresses.append(contentsOf: g.addresses)
        self.addresses = addresses
    }
}

extension FuncBox: Equatable
{
    public static func == <T>(l: FuncBox<T, U>, r: FuncBox<T, U>) -> Bool
    {
        // Comment-Out: Only checking `impl` is not enough when function composition takes place.
//        return _peekFunc(l.impl) == _peekFunc(r.impl)

        let count = l.addresses.count
        guard count == r.addresses.count else { return false }

        for i in 0..<count where l.addresses[i] != r.addresses[i] {
            return false
        }

        return true
    }
}

// MARK: Custom Operators

prefix operator ^

/// Shortcut for creating `FuncBox` from `(T) -> U`.
public prefix func ^ <T, U>(f: @escaping (T) -> U) -> FuncBox<T, U>
{
    return FuncBox(f)
}

// Comment-Out:
// This code will not work because `FuncBox` will refer to the closure
// created inside of this prefix-func, which is always a fixed callsite for arbitrary `value`
// thus `FuncBox` equality will not make sense.
//public prefix func ^ <T, U>(value: @autoclosure () -> U) -> FuncBox<T, U>
//{
//    return FuncBox { _ in value } // Don't create closure here!
//}

// MARK: peekFunc

/// Hacky function equality.
/// - https://gist.github.com/dankogai/b03319ce427544beb5a4
/// - http://qiita.com/dankogai/items/ab407918dba590016058 (Japanese)
private func _peekFunc<A, R>(_ f: (A) -> R) -> (fp: Int, ctx: Int)
{
    let (_, low) = unsafeBitCast(f, to: (Int, Int).self)
    let offset = MemoryLayout<Int>.size == 8 ? 16 : 12
    let ptr = UnsafePointer<Int>(bitPattern: low + offset)
    return (ptr!.pointee, ptr!.successor().pointee)
}

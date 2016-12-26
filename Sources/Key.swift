/// Identity-equatable (`===`) class used in `VTree` for better performance.
public final class Key
{
    public init() {}
}

// MARK: Key Cache

private var _keyCache = [AnyHashable: Key]()

/// Easy `Key` generator using key-cache, e.g. `key("button")`, `key(1)`.
public func key(_ keyName: AnyHashable) -> Key
{
    if let key = _keyCache[keyName] {
        return key
    }
    else {
        let key = Key()
        _keyCache[keyName] = key
        return key
    }
}

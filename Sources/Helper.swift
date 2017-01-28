/// Combine hashValues.
internal func _hashValue<X: Hashable, Y: Hashable>(x: X, y: Y) -> Int
{
    return (31 &* x.hashValue) &+ y.hashValue
}

/// Compare 2 `Any`s using the power of `AnyObject`.
internal func _objcEqual(_ any1: Any, _ any2: Any) -> Bool
{
    return (any1 as AnyObject).isEqual(any2)
}

/// Safe conversion from nullable-`Any` to `Any?`
/// for avoiding KVC to send `NSNull` on `setValue(nullableAny, forKey: ...)`.
/// - TODO: Find a better solution.
internal func _toOptionalAny(_ any: Any) -> Any?
{
    let mirror = Mirror(reflecting: any)
    if mirror.displayStyle == .optional && mirror.children.isEmpty {
        return nil
    }
    else {
        return any
    }
}

/// Binary search for an index in the interval `left...right`.
/// This is analogous to `(left...right).contains(where: indexes.contains)`.
internal func _indexInRange(_ indexes: [Int], _ left: Int, _ right: Int) -> Bool
{
    if indexes.isEmpty { return false }

    var minIndex = 0
    var maxIndex = indexes.count - 1
    var currentIndex: Int
    var currentItem: Int

    while minIndex <= maxIndex {
        currentIndex = (maxIndex + minIndex) / 2
        currentItem = indexes[currentIndex]

        if minIndex == maxIndex {
            return currentItem >= left && currentItem <= right
        }
        else if currentItem < left {
            minIndex = currentIndex + 1
        }
        else if currentItem > right {
            maxIndex = currentIndex - 1
        }
        else {
            return true
        }
    }

    return false
}

// MARK: Collection + safe subscript

extension Collection
{
    internal subscript (safe index: Index) -> Iterator.Element? {
        return index < self.endIndex ? self[index]: nil
    }
}

// MARK: Dictionary + map

extension Dictionary
{
    internal func map<K: Hashable, V>(_ transform: (Key, Value) -> (K, V)) -> [K: V]
    {
        var results: [K: V] = [:]
        for (key, value) in self {
            let (key2, value2) = transform(key, value)
            results.updateValue(value2, forKey: key2)
        }
        return results
    }
}

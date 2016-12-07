/// Mutable boxing reference type.
internal final class MutableBox<T>
{
    private var _value: T

    internal init(_ value: T)
    {
        self._value = value
    }

    internal var value: T
    {
        get {
            return self._value
        }
        set {
            self._value = newValue
        }
    }
}

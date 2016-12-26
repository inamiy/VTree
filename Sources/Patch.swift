/// Container of `PatchStep`s.
public struct Patch<Msg: Message>
{
    /// Dictionary with "key = treeIndex" and "value = array of PatchStep".
    internal typealias Steps = [Int: [PatchStep<Msg>]]

    internal let oldTree: AnyVTree<Msg>
    internal let steps: Steps
}

extension Patch: CustomStringConvertible
{
    public var description: String
    {
        return "Patch(steps: \(steps))"
    }
}

// MARK: PatchStep

internal enum PatchStep<Msg: Message>: Equatable
{
    case replace(AnyVTree<Msg>)
    case props(removes: [String], updates: [String: Any], inserts: [String: Any])
    case handlers(removes: [SimpleEvent], updates: HandlerMapping<Msg>, inserts: HandlerMapping<Msg>)
    case gestures(removes: [GestureEvent], updates: GestureMapping<Msg>, inserts: GestureMapping<Msg>)
    case removeChild(AnyVTree<Msg>)
    case insertChild(AnyVTree<Msg>)
    case reorderChildren(Reorder)

    internal static func == (lhs: PatchStep, rhs: PatchStep) -> Bool
    {
        switch (lhs, rhs) {
            case let (.replace(l), .replace(r)) where l.key === r.key:
                return true
            case let (.props(l), .props(r)) where l.0 == r.0 && _objcEqual(l.1, r.1) && _objcEqual(l.2, r.2):
                return true
            case let (.handlers(l), .handlers(r)) where l.0 == r.0 && l.1 == r.1 && l.2 == r.2:
                return true
            case let (.gestures(l), .gestures(r)) where l.0 == r.0 && l.1 == r.1 && l.2 == r.2:
                return true
            case let (.removeChild(l), .removeChild(r)) where l.key === r.key:
                return true
            case let (.insertChild(l), .insertChild(r)) where l.key === r.key:
                return true
            case let (.reorderChildren(l), .reorderChildren(r)) where l == r:
                return true
            default:
                return false
        }
    }

    internal var handlers: (removes: [SimpleEvent], updates: HandlerMapping<Msg>, inserts: HandlerMapping<Msg>)?
    {
        guard case let .handlers(removes, updates, inserts) = self else {
            return nil
        }
        return (removes: removes, updates: updates, inserts: inserts)
    }

    internal var gestures: (removes: [GestureEvent], updates: GestureMapping<Msg>, inserts: GestureMapping<Msg>)?
    {
        guard case let .gestures(removes, updates, inserts) = self else {
            return nil
        }
        return (removes: removes, updates: updates, inserts: inserts)
    }
}

// MARK: Reorder

internal struct Reorder: Equatable, CustomStringConvertible
{
    internal let removes: [Remove]
    internal let inserts: [Insert]

    internal init(removes: [Remove] = [], inserts: [Insert] = [])
    {
        self.removes = removes
        self.inserts = inserts
    }

    internal init(removes: [(Key?, Int)], inserts: [(Key?, Int)])
    {
        self.removes = removes.map(Remove.init)
        self.inserts = inserts.map(Insert.init)
    }

    internal var isEmpty: Bool
    {
        return self.removes.isEmpty && self.inserts.isEmpty
    }

    internal var description: String
    {
        return "Reorder(removes: \(removes), inserts: \(inserts))"
    }

    internal static func == (lhs: Reorder, rhs: Reorder) -> Bool
    {
        return lhs.removes == rhs.removes && lhs.inserts == rhs.inserts
    }
}

extension Reorder
{
    internal struct Remove: Equatable, CustomStringConvertible
    {
        internal let key: Key?
        internal let fromIndex: Int

        internal init(key: Key?, from fromIndex: Int)
        {
            self.key = key
            self.fromIndex = fromIndex
        }

        internal var description: String
        {
            return "(key: \(key), from: \(fromIndex))"
        }

        internal static func == (lhs: Remove, rhs: Remove) -> Bool
        {
            return lhs.key === rhs.key && lhs.fromIndex == rhs.fromIndex
        }
    }

    internal struct Insert: Equatable, CustomStringConvertible
    {
        internal let key: Key?
        internal let toIndex: Int

        internal init(key: Key?, to toIndex: Int)
        {
            self.key = key
            self.toIndex = toIndex
        }

        internal var description: String
        {
            return "(key: \(key), to: \(toIndex))"
        }

        internal static func == (lhs: Insert, rhs: Insert) -> Bool
        {
            return lhs.key === rhs.key && lhs.toIndex == rhs.toIndex
        }
    }
}

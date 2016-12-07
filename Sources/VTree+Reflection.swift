/// Additional protocol for automatically generating `props`
/// from given (type-safe) `propsData` using `Mirror`.
public protocol PropsReflectable
{
    associatedtype PropsData

    /// Props dataset that will be reflected to `VTree.props`.
    var propsData: PropsData { get }
}

extension VTree where Self: PropsReflectable
{
    // Default implementation.
    public var props: [String : Any]
    {
        return Mirror(reflecting: self.propsData)._allChildren
    }
}

extension Mirror
{
    /// Collect all properties in class hierarchy.
    fileprivate var _allChildren: [String : Any]
    {
        var properties: [String : Any] = [:]

        for case let (key?, value) in self.children {
            properties[key] = value
        }

        if let superclassMirror = self.superclassMirror {
            for (key, value) in superclassMirror._allChildren {
                properties[key] = value
            }
        }

        return properties
    }
}

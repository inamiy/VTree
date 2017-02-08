#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

private var isVTreeViewKey: UInt8 = 0

extension View
{
    internal var isVTreeView: Bool
    {
        get {
            return objc_getAssociatedObject(self, &isVTreeViewKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &isVTreeViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

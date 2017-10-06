#if os(iOS) || os(tvOS)

import UIKit

extension UIView
{
    // MARK: KVC-compliant properties

    @objc public var vtree_cornerRadius: CGFloat
    {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}

#endif

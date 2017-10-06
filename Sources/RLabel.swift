#if os(iOS) || os(tvOS)
import UIKit

/// UILabel subclass for adding KVC-compliant properties to control subview's properties.
public final class RLabel: UILabel
{
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: KVC-compliant properties

    @objc public var vtree_numberOfLines: Int
    {
        get {
            return self.numberOfLines
        }
        set {
            self.numberOfLines = newValue
        }
    }
}

#elseif os(macOS)

import AppKit

/// UILabel subclass for adding KVC-compliant properties to control subview's properties.
public final class RLabel: NSTextField
{
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: KVC-compliant properties

    @objc public var vtree_numberOfLines: Int
    {
        get {
            return self.maximumNumberOfLines
        }
        set {
            self.maximumNumberOfLines = newValue
        }
    }
}

#endif

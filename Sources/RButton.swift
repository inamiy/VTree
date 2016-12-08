#if os(iOS) || os(tvOS)
import UIKit

/// UIButton subclass for adding KVC-compliant properties to control subview's properties.
public final class RButton: UIButton
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

    public var title: String?
    {
        get {
            return self.title(for: .normal)
        }
        set {
            self.setTitle(newValue, for: .normal)
        }
    }

    public var titleColor: UIColor?
    {
        get {
            return self.titleColor(for: .normal)
        }
        set {
            self.setTitleColor(newValue, for: .normal)
        }
    }

    public var titleFont: UIFont?
    {
        get {
            return self.titleLabel?.font
        }
        set {
            self.titleLabel?.font = newValue
        }
    }
}

#endif

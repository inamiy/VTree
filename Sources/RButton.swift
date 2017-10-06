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

    @objc public var vtree_title: String?
    {
        get {
            return self.title(for: .normal)
        }
        set {
            self.setTitle(newValue, for: .normal)
        }
    }

    @objc public var vtree_attributedTitle: NSAttributedString?
    {
        get {
            return self.attributedTitle(for: .normal)
        }
        set {
            self.setAttributedTitle(newValue, for: .normal)
        }
    }

    @objc public var vtree_titleColor: UIColor?
    {
        get {
            return self.titleColor(for: .normal)
        }
        set {
            self.setTitleColor(newValue, for: .normal)
        }
    }

    @objc public var vtree_font: UIFont?
    {
        get {
            return self.titleLabel?.font
        }
        set {
            self.titleLabel?.font = newValue
        }
    }

    @objc public var vtree_numberOfLines: Int
    {
        get {
            return self.titleLabel?.numberOfLines ?? 0
        }
        set {
            self.titleLabel?.numberOfLines = newValue
        }
    }
}

#endif

#if os(iOS) || os(tvOS)

    import UIKit

    public typealias Color = UIColor
    public typealias Image = UIImage
    public typealias Font = UIFont

    public typealias View = UIView
    public typealias ImageView = UIImageView
    public typealias Label = UILabel
    public typealias Button = RButton

    public typealias GestureRecognizer = UIGestureRecognizer
    public typealias GestureState = UIGestureRecognizerState

#elseif os(macOS)

    import AppKit

    public typealias Color = NSColor
    public typealias Image = NSImage
    public typealias Font = NSFont

    public typealias View = NSView
    public typealias ImageView = NSImageView
    public typealias Label = NSTextField
    public typealias Button = NSButton

    public typealias GestureRecognizer = NSGestureRecognizer
    public typealias GestureState = NSGestureRecognizerState

#endif

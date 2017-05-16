#if os(macOS)

// TODO: Not tested yet.

import AppKit

extension NSView
{
    internal var backgroundColor: NSColor?
    {
        get {
            guard let layer = layer, let backgroundColor = layer.backgroundColor else { return nil }
            return NSColor(cgColor: backgroundColor)
        }

        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }

    internal func insertSubview(_ view: NSView, at index: Int)
    {
        self.addSubview(view, positioned: .above, relativeTo: self.subviews[index])
    }
}

extension NSTextField
{
    internal var text: String?
    {
        get {
            return self.stringValue
        }
        set {
            self.stringValue = newValue ?? ""
        }
    }

    internal var attributedText: NSAttributedString?
    {
        get {
            return self.attributedStringValue
        }
        set {
            self.attributedStringValue = newValue ?? NSAttributedString()
        }
    }

    internal var textAlignment: NSTextAlignment
    {
        get {
            return self.alignment
        }
        set {
            self.alignment = newValue
        }
    }
}

extension NSControl
{
    internal func addHandler(_ handler: @escaping (NSControl) -> ())
    {
        let target = self.vtree.associatedValue { _ in CocoaTarget<NSControl>(handler) { $0 as! NSControl } }

        self.target = target
        self.action = #selector(target.sendNext)
    }
}

#endif

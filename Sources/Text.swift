public enum Text
{
    case text(String)
    case attributedText(NSAttributedString)
}

extension Text
{
    var text: String?
    {
        guard case let .text(text) = self else { return nil }
        return text
    }

    var attributedText: NSAttributedString?
    {
        guard case let .attributedText(attributedText) = self else { return nil }
        return attributedText
    }
}

extension Text: ExpressibleByStringLiteral
{
    public init(stringLiteral value: String)
    {
        self = .text(value)
    }

    public init(extendedGraphemeClusterLiteral value: String)
    {
        self = .text(value)
    }

    public init(unicodeScalarLiteral value: String)
    {
        self = .text(value)
    }
}

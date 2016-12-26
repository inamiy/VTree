public protocol RawStringRepresentable: RawRepresentable
{
    init?(rawValue: String)
    var rawValue: String { get }
}

import Foundation

private let _spellOutFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    return formatter
}()

/// e.g. "23" becomes "twenty-three".
public func spellOut(_ number: Int) -> String?
{
    return _spellOutFormatter.string(from: NSNumber(value: number))
}

internal enum Debug
{
    static func print(_ message: Any)
    {
        #if VTREE_DEBUG
        Swift.print(message)
        #endif
    }
}

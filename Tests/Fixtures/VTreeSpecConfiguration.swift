import Quick
#if os(iOS) || os(tvOS)
    import UIKit
#endif

class VTreeSpecConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        #if os(iOS) || os(tvOS)
            configuration.beforeSuite {
                UIControl._initialize()
            }
        #endif
    }
}

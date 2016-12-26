import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var program: Program?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.program = Program()

        let mainView = self.window?.rootViewController?.view
        mainView?.backgroundColor = .white
        mainView?.addSubview(self.program!.rootView!)

        return true
    }

}

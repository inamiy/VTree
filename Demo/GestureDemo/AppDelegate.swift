import UIKit
import DemoFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var program: Program<Model, Msg>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.program = Program(model: .initial, update: update, view: view)

        let mainView = self.window?.rootViewController?.view
        mainView?.backgroundColor = .white
        mainView?.addSubview(self.program!.rootView!)

        return true
    }

}

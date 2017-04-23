import UIKit
import DemoFramework
import VTreeDebugger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var program: Any?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
//        let program = Program(model: .initial, update: update, view: view)
        let program = debugProgram(debug: false, model: .initial, update: update, view: view)
        self.program = program

        let mainView = self.window?.rootViewController?.view
        mainView?.backgroundColor = .white
        mainView?.addSubview(program.rootView!)

        return true
    }

}

// MARK: VTreeDebugger

extension Model: VTreeDebugger.DebuggableModel
{
    var description: String
    {
        return "\(self.count)"
    }
}

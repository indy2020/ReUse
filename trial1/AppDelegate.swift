import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        // Create an instance of OpeningScreen
        let openingScreen = OpeningScreen()

        // Embed OpeningScreen in a navigation controller
        let navigationController = UINavigationController(rootViewController: openingScreen)

        // Set the navigation controller as the root view controller
        window?.rootViewController = navigationController

        // Make the window visible
        window?.makeKeyAndVisible()

        // Initialize Google Sign-In
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
            } else {
                // Show the app's signed-in state.
            }
        }

        return true
    }

    // MARK: - Google Sign-In

    // Handle the URL that your application receives at the end of the authentication process
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

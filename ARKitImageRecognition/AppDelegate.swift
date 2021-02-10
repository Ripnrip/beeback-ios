/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Application's delegate.
*/

import UIKit
import ARKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
    
    var loginCoordinator: LoginCoordinator?
    var mainCoordinator: MainCoordinator?

          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        guard ARWorldTrackingConfiguration.isSupported else {
//            fatalError("""
//                ARKit is not available on this device. For apps that require ARKit
//                for core functionality, use the `arkit` key in the key in the
//                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
//                the app from installing. (If the app can't be installed, this error
//                can't be triggered in a production scenario.)
//                In apps where AR is an additive feature, use `isSupported` to
//                determine whether to show UI for launching AR experiences.
//            """) // For details, see https://developer.apple.com/documentation/arkit
//        }
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Firebase
        FirebaseApp.configure()
        
        // create the login navigation controller to be used for our app
        let navController = UINavigationController()
        
        // create the main navigation controller to be used for our app
        let mainNavController = MainNavigationViewController()
        
        // send that into our coordinator so that it can display view controllers
        loginCoordinator = LoginCoordinator(navigationController: navController)
        mainCoordinator = MainCoordinator(navigationController: navController)

        // tell the coordinator to take over control
        //try! Auth.auth().signOut()
        
        if Auth.auth().currentUser == nil {
            loginCoordinator?.start()
        } else {
            mainCoordinator?.start()
        }

        // create a basic UIWindow and activate it
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        return true
    }
}

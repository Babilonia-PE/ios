//
//  AppDelegate.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Core
import Swinject
import GoogleMaps
import GooglePlaces
import Firebase
import Stripe

#if canImport(BuildInfo)
import BuildInfo
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let container = Container()
    private let userSessionController = UserSessionController()
    
    var window: UIWindow?
    private var applicationFlowCoordinator: ApplicationFlowCoordinator!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppStyle.default.applyAppearance()
        GMSServices.provideAPIKey("AIzaSyCpGfIjj1B1wxgOkjdog6Da_1xetzn9OnI")
        GMSPlacesClient.provideAPIKey("AIzaSyCpGfIjj1B1wxgOkjdog6Da_1xetzn9OnI")
        
        FirebaseApp.configure()

        Stripe.setDefaultPublishableKey(Environment.default.stripePublishableKey)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        #if canImport(BuildInfo)
        BuildInfo.shared.activate(with: window!)
        #endif
        
        applicationFlowCoordinator = ApplicationFlowCoordinator(
            window: window!,
            userSessionController: userSessionController
        )
        applicationFlowCoordinator.execute()
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        let handled = DynamicLinks
            .dynamicLinks()
            .handleUniversalLink(userActivity.webpageURL!) { [weak self] (dynamiclink, _) in
                if let url = dynamiclink?.url {
                    _ = self?.applicationFlowCoordinator.handleDeeplink(link: url)
                }
            }

        return handled
    }

}

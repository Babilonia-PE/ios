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
//import Stripe
import FBSDKCoreKit

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
        //testing
        GMSServices.provideAPIKey("AIzaSyDLAYwmDwRtktHg_tc71yYHEK7auabLDP8")
        GMSPlacesClient.provideAPIKey("AIzaSyDLAYwmDwRtktHg_tc71yYHEK7auabLDP8")
        
        //prod
        //GMSServices.provideAPIKey("AIzaSyDIjFGC9agH6MASWS7ibYQfxlFbbw4du00")
        //GMSPlacesClient.provideAPIKey("AIzaSyDIjFGC9agH6MASWS7ibYQfxlFbbw4du00")
        
        FirebaseApp.configure()

//        Stripe.setDefaultPublishableKey(Environment.default.stripePublishableKey)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        #if canImport(BuildInfo)
        BuildInfo.shared.activate(with: window!)
        #endif
        
        applicationFlowCoordinator = ApplicationFlowCoordinator(
            window: window!,
            userSessionController: userSessionController
        )
        applicationFlowCoordinator.execute()
        
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions)
        
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

    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        }
}

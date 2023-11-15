platform :ios, '13.0'

# Specify which schemes refer to the debug configuration
project 'Babilonia', {
    'Debug' => :debug,
    'Staging-Debug' => :debug,
    'Production-Debug' => :debug
}


abstract_target 'Shared' do
    use_frameworks!
    inhibit_all_warnings!
    
    # code style rules
    pod 'SwiftLint', '~> 0.39.2'
    
    # DI
    pod 'Swinject', '~> 2.7.1'
    pod 'SwinjectAutoregistration', '~> 2.7.0'
    
    # FRP
    pod 'RxCocoa', '5.1.1'
    pod 'NSObject+Rx', '~> 5.1.0'
    
    # Network
    pod 'YALAPIClient/Alamofire', :git => 'https://gitlab.com/babilonia-public/babilonia-public.git'

    #Payments
#    pod 'Stripe', '19.0.1'
    
    target 'Core' do
        # db client component
        pod 'DBClient/CoreData', :git => 'https://github.com/Yalantis/DBClient', :branch => 'fetch-hotfix'
    end
    
    target 'Babilonia' do
     #   pod_dev_tools
        
        pod 'Firebase/Crashlytics'
        pod 'Firebase/Analytics'
        pod 'FirebaseUI/Phone', '~> 12.0.0'
        pod 'Firebase/DynamicLinks'
        
        # Facebook
        
        pod 'FBSDKCoreKit', '~> 11.1.0'
        pod 'FBSDKLoginKit'
        pod 'FBSDKShareKit'
        
        # Image fetching
        pod 'Kingfisher', '~> 5.13.4'
        pod 'SVGKit'
        
        # Tools
        pod 'SwiftGen', '~> 6.4.0'
        
        # Utils
        pod 'JGProgressHUD', '~> 2.1'
        pod 'SwiftMessages', '~> 8.0.2'
        pod 'ESTabBarController-swift', '~> 2'
        pod 'PhoneNumberKit', '~> 3.2.0'
        
        pod 'GoogleMaps', '~> 3.10.0'
        pod 'GooglePlaces', '~> 3.10.0'
        
        pod 'CountryPickerView', '~> 3.3.0'

	pod 'MultiSlider', '~> 1.10.12 '
    end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end


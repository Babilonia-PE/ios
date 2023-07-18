platform :ios, '11.0'

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
    pod 'YALAPIClient/Alamofire', :git => 'https://github.com/Yalantis/APIClient.git', :tag => '2.9'

    #Payments
    pod 'Stripe', '19.0.1'

    target 'Core' do
        # db client component
        pod 'DBClient/CoreData', '~> 1.4.2'
    end
    
    target 'Babilonia' do
        pod_dev_tools
        
        pod 'Firebase/Crashlytics'
        pod 'Firebase/Analytics'
        pod 'FirebaseUI/Phone'
        pod 'Firebase/DynamicLinks'
        
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


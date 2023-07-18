import UIKit

enum AlertStyle {
    
    case error, success, info
    
}

// swiftlint:disable function_parameter_count
protocol Alert: HUD {
    
    /**
     - parameter viewController: `UIViewController` on which Alert should be shown
     - parameter style: `AlertStyle` of Alert
     - parameter title: Optional title of Alert
     - parameter message: Message to show
     - parameter actionTitle: Optional Title of Button in Alert if it exists
     */
    
    func show(on viewController: UIViewController,
              with style: AlertStyle,
              title: String?,
              iconImage: UIImage?,
              message: String?,
              actionTitle: String?)
    
    func hide(from viewController: UIViewController)
    
}

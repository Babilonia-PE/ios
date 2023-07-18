import UIKit

/// Interface for presenting Alert
protocol AlertPresentable {
    
    func showAlert(with style: AlertStyle, title: String?, iconImage: UIImage?, message: String?, actionTitle: String?)
    func hideAlert()
    
    /**
     Shows Alert with default Title according to style
     */
    func showDefaultAlert(with style: AlertStyle, message: String)
    
}

extension AlertPresentable {
    
    func showDefaultAlert(with style: AlertStyle, message: String) {
        let title: String
        var icon: UIImage?
        var subtitle: String?
        
        switch style {
        case .error:
            title = L10n.Hud.Alert.Error.title
            icon = Asset.Common.errorIcon.image
            subtitle = message
            
        case .success:
            title = message
            icon = Asset.Common.successIcon.image
            
        case .info:
            title = L10n.Hud.Alert.Info.title
        }
        
        showAlert(with: style, title: title, iconImage: icon, message: subtitle, actionTitle: nil)
    }
    
}

/// Interface that requires Alert instance to work with
protocol AlertApplicable: AlertPresentable {
    
    // Need to avoid type declaration in implementation
    associatedtype AlertType: Alert
    
    var alert: AlertType { get }
    
}

extension AlertApplicable where Self: UIViewController {
    
    func showAlert(with style: AlertStyle, title: String? = nil, iconImage: UIImage? = nil, message: String?,
                   actionTitle: String? = nil) {
        alert.show(
            on: self,
            with: style,
            title: title,
            iconImage: iconImage,
            message: message,
            actionTitle: actionTitle
        )
    }
    
    func hideAlert() {
        alert.hide(from: self)
    }
    
}

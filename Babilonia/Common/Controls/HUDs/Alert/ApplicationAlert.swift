import SwiftMessages

// swiftlint:disable function_parameter_count
final class ApplicationAlert: Alert {
    
    private(set) var state: HUDState = .initialized {
        didSet {
            stateDidChange?(state)
        }
    }
    var stateDidChange: ((HUDState) -> Void)?
    
    // MARK: - Alert Presentation
    
    func show(on viewController: UIViewController, with style: AlertStyle, title: String?, iconImage: UIImage?,
              message: String?, actionTitle: String?) {
        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureDropShadow()
        messageView.configureContent(
            title: title,
            body: message,
            iconImage: iconImage,
            iconText: nil,
            buttonImage: nil,
            buttonTitle: actionTitle,
            buttonTapHandler: nil
        )
        messageView.configureIcon(withSize: CGSize(width: 48.0, height: 48.0))
        messageView.titleLabel?.font = FontFamily.AvenirLTStd._85Heavy.font(size: 16.0)
        messageView.titleLabel?.textColor = Asset.Colors.vulcan.color
        messageView.titleLabel?.minimumScaleFactor = 0.5
        messageView.titleLabel?.adjustsFontSizeToFitWidth = true
        messageView.bodyLabel?.font = FontFamily.AvenirLTStd._55Roman.font(size: 12.0)
        messageView.bodyLabel?.textColor = Asset.Colors.trout.color
        
        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 5.0)
        config.presentationContext = .window(windowLevel: .statusBar)
        config.eventListeners.append { [weak self] event in
            switch event {
            case .didShow:
                self?.state = .presenting
                
            case .didHide:
                self?.state = .hidden
                
            default:
                break
            }
        }
        
        SwiftMessages.show(config: config, view: messageView)
    }
    
    func hide(from viewController: UIViewController) {
        dismissAlertIfNeeded()
    }
    
    private func dismissAlertIfNeeded() {
        if state == .presenting {
            dismissAlert()
        }
    }
    
    private func dismissAlert() {
        SwiftMessages.hide()
    }
    
}

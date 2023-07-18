import UIKit

class KeyboardNotificationInfoAdapter {
    
    static func info(from notification: Foundation.Notification) -> KeyboardNotificationInfo {
        var info = KeyboardNotificationInfo()
        
        guard let userInfo = notification.userInfo else {
            return info
        }
        
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            info.keyboardSize = keyboardSize
        }
        if let animationDuration: TimeInterval =
            (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            info.animationDuration = animationDuration
        }
        if let animationCurve: Int =
            (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let curve = UIView.AnimationCurve(rawValue: animationCurve) {
            let options: UIView.AnimationOptions
            
            switch curve {
            case .easeInOut:
                options = []
            case .easeIn:
                options = .curveEaseIn
            case .easeOut:
                options = .curveEaseOut
            default:
                options = UIView.AnimationOptions(rawValue: UInt(animationCurve) << 16)
            }
            
            info.animationOptions = options
        }
        
        return info
    }
    
}

import UIKit

protocol Spinner: HUD {
    
    func show(on view: UIView, text: String?, blockUI: Bool)
    func hide(from view: UIView)
    
}

import UIKit

enum SpinnerState {
    
    case visible(text: String?)
    case hidden
    
}

protocol SpinnerPresentable {
    
    func showSpinner(with text: String?, blockUI: Bool)
    func hideSpinner()
    func handleSpinnerState(_ state: SpinnerState, blockUI: Bool)
    
}

protocol SpinnerApplicable: SpinnerPresentable {
    
    associatedtype SpinnerType: Spinner
    
    var spinner: SpinnerType { get }
    
}

extension SpinnerApplicable where Self: UIViewController {
    
    func showSpinner(with text: String? = nil, blockUI: Bool = true) {
        spinner.show(on: view, text: text, blockUI: blockUI)
    }
    
    func hideSpinner() {
        spinner.hide(from: view)
    }
    
    func handleSpinnerState(_ state: SpinnerState, blockUI: Bool = true) {
        switch state {
        case .visible(let text):
            showSpinner(with: text, blockUI: true)
            
        case .hidden:
            hideSpinner()
        }
    }
    
}

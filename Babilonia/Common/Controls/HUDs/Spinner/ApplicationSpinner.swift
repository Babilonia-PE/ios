//
//  ApplicationSpinner.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import JGProgressHUD

final class AppSpinner: Spinner {
    
    private(set) var state: HUDState = .initialized {
        didSet {
            stateDidChange?(state)
        }
    }
    var stateDidChange: ((HUDState) -> Void)?
    
    private let hud = JGProgressHUD(style: .dark)
    
    func show(on view: UIView, text: String?, blockUI: Bool) {
        hud.interactionType = blockUI ? .blockAllTouches : .blockNoTouches
        hud.textLabel.text = text
        
        hud.show(in: view)
        
        state = .presenting
    }
    
    func hide(from view: UIView) {
        guard state == .presenting else { return }
        
        hud.dismiss()
        state = .hidden
    }
    
}

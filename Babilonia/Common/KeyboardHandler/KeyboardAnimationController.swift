import UIKit

// swiftlint:disable closure_end_indentation

final class KeyboardAnimationController {
    
    typealias KeyboardFrameHandler = ((CGRect) -> Void)
    typealias KeyboardAnimationCompletionHandler = ((CGRect, Bool) -> Void)
    
    var willAnimatedKeyboardPresentation: KeyboardFrameHandler?
    var animateKeyboardPresentation: KeyboardFrameHandler?
    var didAnimateKeyboardPresentation: KeyboardAnimationCompletionHandler?
    
    var willAnimatedKeyboardDismissal: KeyboardFrameHandler?
    var animateKeyboardDismissal: KeyboardFrameHandler?
    var didAnimateKeyboardDismissal: KeyboardAnimationCompletionHandler?
    
    var willAnimatedKeyboardFrameChange: KeyboardFrameHandler?
    var animateKeyboardFrameChange: KeyboardFrameHandler?
    var didAnimateKeyboardFrameChange: KeyboardAnimationCompletionHandler?
    
    var hasSelectedFields: (() -> Bool)?
    
    fileprivate var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    deinit {
        if tracking {
            endTracking()
        }
    }
    
    fileprivate(set) var tracking = false
    fileprivate(set) var keyboardPresented = false
    
    func beginTracking() {
        tracking = true
        
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrame(_:)),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil
        )
    }
    
    func endTracking() {
        tracking = false
        notificationCenter.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc
    fileprivate func keyboardWillShow(_ notification: Foundation.Notification) {
        let keyboardInfo = KeyboardNotificationInfoAdapter.info(from: notification)
        if let frame = keyboardInfo.keyboardSize,
            let duration = keyboardInfo.animationDuration,
            let curve = keyboardInfo.animationOptions,
            let isLocal = (notification as NSNotification).userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
            isLocal && (hasSelectedFields?() ?? true) {
            keyboardPresented = true
            
            willAnimatedKeyboardPresentation?(frame)
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: curve,
                animations: {
                    self.animateKeyboardPresentation?(frame)
            },
                completion: { finished in
                    self.didAnimateKeyboardPresentation?(frame, finished)
            })
        }
    }
    
    @objc
    fileprivate func keyboardWillHide(_ notification: Foundation.Notification) {
        let keyboardInfo = KeyboardNotificationInfoAdapter.info(from: notification)
        if let frame = keyboardInfo.keyboardSize,
            let duration = keyboardInfo.animationDuration,
            let curve = keyboardInfo.animationOptions,
            let isLocal = (notification as NSNotification).userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
            isLocal && (hasSelectedFields?() ?? true) {
            keyboardPresented = false
            
            willAnimatedKeyboardDismissal?(frame)
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: curve,
                animations: {
                    self.animateKeyboardDismissal?(frame)
            },
                completion: { finished in
                    self.didAnimateKeyboardDismissal?(frame, finished)
            })
        }
    }
    
    @objc
    fileprivate func keyboardDidChangeFrame(_ notification: Foundation.Notification) {
        let keyboardInfo = KeyboardNotificationInfoAdapter.info(from: notification)
        if let frame = keyboardInfo.keyboardSize,
            let duration = keyboardInfo.animationDuration,
            let curve = keyboardInfo.animationOptions,
            let isLocal = (notification as NSNotification).userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
            isLocal && keyboardPresented && (hasSelectedFields?() ?? true) {
            willAnimatedKeyboardFrameChange?(frame)
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: curve,
                animations: {
                    self.animateKeyboardFrameChange?(frame)
            },
                completion: { finished in
                    self.didAnimateKeyboardFrameChange?(frame, finished)
            })
        }
    }
    
}

// swiftlint:enable closure_end_indentation

//
//  InputFieldViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

final class InputFieldViewModel {
    
    enum EditingMode {
        case text, action(() -> Void)
    }
    
    var titleUpdated: Driver<String> { return title.asDriver().distinctUntilChanged() }
    var textUpdated: Driver<String> {
        let result: Driver<String>
        if case .action = editingMode {
            result = text.asDriver().distinctUntilChanged()
        } else {
            result = text.asDriver()
        }
        return result.map {
            [unowned self] in self.textFormatter?.formatted($0) ?? $0
        }
    }
    var isEditingUpdated: Signal<Bool> { return isEditing.asSignal() }
    
    var shouldValidateOnStart: Bool { return !text.value.isEmpty }
    
    var textCount: Int { return text.value.count }
    
    /// making caret static here to prevent glitches after formatting
    var caretShouldBeStatic: Bool { return textFormatter != nil }
    
    var validationDriver: Driver<Bool> {
        return text.asDriver().map { [unowned self] text in
            self.validator.flatMap {
                switch $0.check(text) {
                case .success: return true
                case .failure: return false
                }
            } ?? true
        }
    }
    var editingDidEnd = PublishSubject<Void>()
    var editingDidBegin = PublishSubject<Void>()
    var textChanged = PublishSubject<String>()
    var textFieldEnabled = PublishSubject<Bool>()
    var shouldChangeTextHandler: ((Int) -> Bool)?
    var shouldChangeTextInRangeHandler: ((String, NSRange) -> Bool)?
    var showError = PublishSubject<ValidationCheckResult?>()

    let editingMode: EditingMode
    let image: UIImage?
    let placeholder: String?
    let keyboardType: UIKeyboardType
    let returnKeyType: UIReturnKeyType
    let autocapitalizationType: UITextAutocapitalizationType
    let autocorrectionType: UITextAutocorrectionType
    let isFieldEnabled: Bool
    let isDefaultOnDismiss: Bool
    let isAttributedText: Bool
    let isSecureText: Bool
    var isHidden: Bool
    private let title: BehaviorRelay<String>
    private let text: BehaviorRelay<String>
    private let validator: Validator?
    private let textFormatter: TextFormatter?
    
    private let isEditing = PublishRelay<Bool>()
    private var customError: ValidationCheckResult?
    
    init(
        title: BehaviorRelay<String>,
        text: BehaviorRelay<String>,
        validator: Validator?,
        textFormatter: TextFormatter? = nil,
        editingMode: EditingMode,
        image: UIImage?,
        placeholder: String?,
        keyboardType: UIKeyboardType = .default,
        returnKeyType: UIReturnKeyType = .done,
        autocapitalizationType: UITextAutocapitalizationType = .words,
        autocorrectionType: UITextAutocorrectionType = .default,
        isFieldEnabled: Bool = true,
        isDefaultOnDismiss: Bool = false,
        isAttributedText: Bool = false,
        isSecureText: Bool = false,
        isHidden: Bool = false
    ) {
        self.title = title
        self.text = text
        self.validator = validator
        self.textFormatter = textFormatter
        self.editingMode = editingMode
        self.image = image
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.isFieldEnabled = isFieldEnabled
        self.isDefaultOnDismiss = isDefaultOnDismiss
        self.isAttributedText = isAttributedText
        self.isSecureText = isSecureText
        self.isHidden = isHidden
    }
    
    func validate() -> ValidationCheckResult {
        if let customError = customError {
            return customError
        } else {
            return validator?.check(text.value) ?? .success
        }
    }

    func setCustomError(error: String?) {
        guard let error = error else {
            customError = nil
            
            return
        }
        customError = ValidationCheckResult.failure(error)
        showError.onNext(customError)
    }
    
    func fieldTapped() {
        switch editingMode {
        case .text:
            isEditing.accept(true)
        case .action(let action):
            action()
        }
    }
    
    func doneTapped() {
        switch editingMode {
        case .text:
            isEditing.accept(false)
        case .action:
            assertionFailure("Done button is only supposed to appear in `text` editing mode")
        }
    }
    
    func updateText(_ text: String) {
        self.text.accept(textFormatter?.initial(text) ?? text)
    }

    func shouldChangeText(for text: String, range: NSRange, count: Int) -> Bool {
        let shouldChangeCount = shouldChangeTextHandler?(count) ?? true
        let shouldChangeRange = shouldChangeTextInRangeHandler?(text, range) ?? true

        return shouldChangeCount && shouldChangeRange
    }
    
    func getTitle() -> String {
        return self.title.value
    }
}

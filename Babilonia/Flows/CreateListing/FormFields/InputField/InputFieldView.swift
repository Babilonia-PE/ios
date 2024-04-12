//
//  InputFieldView.swift
//  Babilonia
//
//  Created by Denis on 6/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class InputFieldView: UIView {
    
    var backgroundView: UIView!
    private var titleLabel: UILabel!
    private var textLabel: UILabel!
    private var placeholderLabel: UILabel!
    private var imageView: UIImageView!
    private var textField: UITextField!
    private var errorLabel: UILabel!
    private var selectButton: UIButton!
    private var buttonsView: UIView!
    private var doneButton: UIButton!
    private var buttonsTitleLabel: UILabel!
    var topConstraint: NSLayoutConstraint?
    private var actionButton: UIButton!

    private let viewModel: InputFieldViewModel
    
    private var errorLabelTopConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: InputFieldViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        layout()
        setupBindings()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateConstraintsIfVisible() {
        let isGone = self.viewModel.isHidden && textField.text!.isEmpty
        if isGone {
            self.goneViews()
        }
    }
    
    // MARK: - private
    
    //swiftlint:disable:next function_body_length
    private func layout() {
        
        backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }

        var rightSideAnchor = trailingAnchor
        
        if let image = viewModel.image {
            imageView = UIImageView()
            imageView.image = image
            addSubview(imageView)
            imageView.layout {
                $0.top == backgroundView.topAnchor + 16.0
                $0.trailing == backgroundView.trailingAnchor - 16.0
            }
            imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800.0), for: .horizontal)
            imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 700.0), for: .horizontal)
            rightSideAnchor = imageView.leadingAnchor
        }
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.height >= 16.0
            $0.top == backgroundView.topAnchor + 7.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == rightSideAnchor - 16.0
        }
        
        textLabel = UILabel()
        addSubview(textLabel)
        textLabel.layout {
            $0.height >= 22.0
            $0.height <= 120.0
            $0.top == titleLabel.bottomAnchor + 1.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == rightSideAnchor - 16.0
            $0.bottom == backgroundView.bottomAnchor - 10.0
        }
        
        placeholderLabel = UILabel()
        addSubview(placeholderLabel)
        placeholderLabel.layout {
            $0.height >= 22.0
            $0.top == titleLabel.bottomAnchor + 1.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == rightSideAnchor - 16.0
        }
        
        textField = viewModel.caretShouldBeStatic ? StaticCaretTextField() : UITextField()
        addSubview(textField)
        textField.layout {
            $0.height >= 22.0
            $0.top == titleLabel.bottomAnchor + 1.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == rightSideAnchor - 16.0
        }
        
        selectButton = UIButton()
        addSubview(selectButton)
        selectButton.layout {
            $0.top == backgroundView.topAnchor
            $0.leading == backgroundView.leadingAnchor
            $0.trailing == backgroundView.trailingAnchor
            $0.bottom == backgroundView.bottomAnchor
        }
        
        errorLabel = UILabel()
        addSubview(errorLabel)
        errorLabel.layout {
            errorLabelTopConstraint = $0.top == backgroundView.bottomAnchor
            $0.leading == backgroundView.leadingAnchor + 16.0
            $0.trailing == backgroundView.trailingAnchor - 16.0
            $0.bottom == bottomAnchor
        }
        
        buttonsView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 44.0))
        
        doneButton = UIButton()
        buttonsView.addSubview(doneButton)
        doneButton.layout {
            $0.trailing == buttonsView.trailingAnchor - 8.0
            $0.top == buttonsView.topAnchor
            $0.bottom == buttonsView.bottomAnchor
        }
        
        buttonsTitleLabel = UILabel()
        buttonsView.addSubview(buttonsTitleLabel)
        buttonsTitleLabel.layout {
            $0.centerX == buttonsView.centerXAnchor
            $0.top == buttonsView.topAnchor
            $0.bottom == buttonsView.bottomAnchor
        }
        
        if let view = actionButton {
            bringSubviewToFront(view)
        }
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 6.0
        backgroundView.layer.borderWidth = 1.0
        backgroundView.layer.borderColor = Asset.Colors.pumice.color.cgColor
        
        titleLabel.textColor = Asset.Colors.osloGray.color
        titleLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12.0)
        
        textLabel.textColor = Asset.Colors.vulcan.color
        textLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 16.0)
        
        errorLabel.textColor = Asset.Colors.flamingo.color
        errorLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 10.0)
        
        placeholderLabel.textColor = Asset.Colors.trout.color
        placeholderLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 16.0)
        placeholderLabel.text = viewModel.placeholder
        
        textField.textColor = Asset.Colors.vulcan.color
        textField.font = FontFamily.AvenirLTStd._65Medium.font(size: 16.0)
        textField.tintColor = Asset.Colors.hippieBlue.color
        textField.keyboardType = viewModel.keyboardType
        textField.returnKeyType = viewModel.returnKeyType
        textField.autocapitalizationType = viewModel.autocapitalizationType
        textField.autocorrectionType = viewModel.autocorrectionType
        textField.isSecureTextEntry = viewModel.isSecureText
        textField.delegate = self
        
        buttonsView.backgroundColor = Asset.Colors.grayNurse.color
        
        doneButton.setTitleColor(Asset.Colors.blue.color, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        doneButton.setTitle(L10n.Buttons.Done.title, for: .normal)
        
        buttonsTitleLabel.textColor = .black
        buttonsTitleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        
        switch viewModel.editingMode {
        case .action:
            textField.isHidden = true
            textLabel.isHidden = false
            textLabel.numberOfLines = 0
        case .text:
            textField.isHidden = false
            textLabel.isHidden = true
            textLabel.numberOfLines = 1
            textField.inputAccessoryView = buttonsView
        }
        
        if viewModel.shouldValidateOnStart {
            processValidation()
        }
        self.updatePlaceholder()
        
        isUserInteractionEnabled = viewModel.isFieldEnabled
        alpha = viewModel.isFieldEnabled ? 1.0 : 0.5
    }
    
    private func setupBindings() {
        viewModel.titleUpdated
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.titleUpdated
            .drive(buttonsTitleLabel.rx.text)
            .disposed(by: disposeBag)

        if viewModel.isAttributedText {
            viewModel.textUpdated
                .map {
                    $0.toAttributed(
                        with: FontFamily.AvenirLTStd._65Medium.font(size: 16.0),
                        lineSpacing: 8.0,
                        alignment: .left,
                        color: Asset.Colors.almostBlack.color,
                        kern: 0.0
                    )
                }
                .drive(textLabel.rx.attributedText)
                .disposed(by: disposeBag)
        } else {
            viewModel.textUpdated
                .drive(textLabel.rx.text)
                .disposed(by: disposeBag)
        }
        
        viewModel.textUpdated.map { [weak self] textValue -> Bool in
            guard let isHidden = self?.viewModel.isHidden else {
                return false
            }
            let isGone = isHidden && textValue.isEmpty
            if isGone {
                self?.goneViews()
            } else {
                self?.viewModel.isHidden = false
                self?.showViews()
            }
            return isGone
        }.drive(self.rx.isHidden)
        .disposed(by: disposeBag)
        
        viewModel.textUpdated
            .map { _ in }
            .drive(onNext: { [weak self] in
                self?.updatePlaceholder()
            })
            .disposed(by: disposeBag)
        if case .action = viewModel.editingMode {
            viewModel.textUpdated
                .skip(1)
                .map { _ in }
                .drive(onNext: { [weak self] in
                    self?.processValidation()
                })
                .disposed(by: disposeBag)
        }
        viewModel.textUpdated
            .drive(textField.rx.text)
            .disposed(by: disposeBag)
        viewModel.isEditingUpdated
            .emit(onNext: { [weak self] value in
                self?.switchEditing(value)
            })
            .disposed(by: disposeBag)

        viewModel.textFieldEnabled
            .bind(to: textField.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.showError
            .subscribe(onNext: { [weak self] _ in
                self?.processValidation()
            })
            .disposed(by: disposeBag)
        setupComponentsBindings()
    }
    
    private func goneViews() {
        topConstraint?.constant = -56.0
    }
    
    private func showViews() {
        topConstraint?.constant = 24.0
    }

    private func setupComponentsBindings() {
        textField.rx.controlEvent(.editingDidBegin)
            .bind { [unowned self] in
                self.setError(isHidden: true)
                self.updatePlaceholder()
                self.selectButton.isHidden = true
                self.backgroundView.layer.borderColor = Asset.Colors.hippieBlue.color.cgColor
                self.viewModel.editingDidBegin.onNext(())
            }
            .disposed(by: disposeBag)
        textField.rx.controlEvent(.editingDidEnd)
            .bind { [unowned self] in
                self.updatePlaceholder()
                self.selectButton.isHidden = false
                self.processValidation()
                self.viewModel.editingDidEnd.onNext(())
            }
            .disposed(by: disposeBag)
        textField.rx.text
            .map { $0 ?? "" }
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.textChanged.onNext(text)
            })
            .disposed(by: disposeBag)
        textField.rx.text
            .map { $0 ?? "" }
            .bind(onNext: { [weak self] text in
                self?.viewModel.updateText(text)
                self?.viewModel.setCustomError(error: nil)
            })
            .disposed(by: disposeBag)

        selectButton.rx.tap
            .bind(onNext: viewModel.fieldTapped)
            .disposed(by: disposeBag)
        doneButton.rx.tap
            .bind(onNext: viewModel.doneTapped)
            .disposed(by: disposeBag)
    }
    
    private func switchEditing(_ isEditing: Bool) {
        if isEditing {
            textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    private func updatePlaceholder() {
        guard let text = textLabel.text, !text.isEmpty else {
            placeholderLabel.text = textField.isFirstResponder ? nil : viewModel.placeholder
            return
        }
        
        placeholderLabel.text = nil
    }
    
    private func processValidation() {
        let shouldHideError = viewModel.isDefaultOnDismiss && textLabel.text?.isEmpty == true
        switch (viewModel.validate(), shouldHideError) {
        case (.success, _), (.failure, true):
            setError(isHidden: true)
        case (.failure(let errorText), false):
            setError(isHidden: false, errorText: errorText)
        }
    }

    private func setError(isHidden: Bool, errorText: String? = nil) {
        let borderColor = isHidden ? Asset.Colors.pumice.color : Asset.Colors.flamingo.color
        backgroundView.layerBorderColor = borderColor
        errorLabel.text = isHidden ? nil : errorText
        errorLabelTopConstraint.constant = isHidden ? 0 : 5
    }
    
}

extension InputFieldView: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
                let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
            }
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count

        return viewModel.shouldChangeText(for: textFieldText, range: range, count: count)
    }

}

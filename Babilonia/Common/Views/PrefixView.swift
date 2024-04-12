//created on  12/04/24

import Foundation
import Core

protocol PrefixViewDelegate: AnyObject {
    
    func didSelectRow(at index: Int)
    
}

final class PrefixView: UIView, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataSet.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSet[row].name // For example
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
    
    weak var delegate: PrefixViewDelegate?
    
    private var selectedIndex = 0
    
    let pickerView = UIPickerView()
    
    let prefixTextField: UITextField = {
        let label = UITextField()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tintColor = .clear
        return label
    }()
    
    let icon: UIImageView = {
        let image = UIImage(systemName: "chevron.down")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let dataSet: [PhonePrefix]
    
    init(dataSet: [PhonePrefix]) {
        self.dataSet = dataSet
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(gesture)
        backgroundColor = .white
        layer.cornerRadius = 6.0
        layer.borderWidth = 1.0
        layer.borderColor = Asset.Colors.pumice.color.cgColor
        prefixTextField.text = dataSet.first?.isoCode?.uppercased()
        prefixTextField.inputView = pickerView
        prefixTextField.textColor = Asset.Colors.vulcan.color
        prefixTextField.font = FontFamily.AvenirLTStd._65Medium.font(size: 16.0)
        addSubview(prefixTextField)
        addSubview(icon)
        NSLayoutConstraint.activate([
            prefixTextField.topAnchor.constraint(equalTo: topAnchor),
            prefixTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            prefixTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            prefixTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            prefixTextField.widthAnchor.constraint(equalToConstant: 50),
            icon.leadingAnchor.constraint(equalTo: prefixTextField.trailingAnchor, constant: 0),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 12),
            icon.topAnchor.constraint(equalTo: topAnchor),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneTapped))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        prefixTextField.inputAccessoryView = toolBar
    }

    @objc func tapped() {
        prefixTextField.becomeFirstResponder()
    }
    
    @objc func doneTapped() {
        prefixTextField.text = dataSet[selectedIndex].isoCode?.uppercased()
        prefixTextField.resignFirstResponder()
        delegate?.didSelectRow(at: selectedIndex)
    }
    
}

//
//  SortPickerView.swift
//

import UIKit

public final class SortPickerView: ActionSheetView {
    
    public var itemSelected: ((Int) -> Void)?

    private struct Constants {
        static let toolbarHeight: CGFloat = 44
    }
    
    override var containerHeight: CGFloat { return 260 }
    
    private var items = [(id: Int, value: String)]()
    private let picker = UIPickerView()
    
    public override init() {
        super.init()
        
        layout()
        picker.backgroundColor = .white
        picker.dataSource = self
        picker.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func select(id: Int) {
        let index = items.enumerated().first(where: { $0.element.id == id })?.offset ?? 0
        picker.selectRow(index, inComponent: 0, animated: false)
    }
    
    public func setupItems(items: [(id: Int, value: String)]) {
        self.items = items
        picker.reloadComponent(0)
    }
    
    private func layout() {
        addToolbar()
        addPicker()
    }
    
    private func addToolbar() {
        let toolbar = UIToolbar(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: UIScreen.main.bounds.width, height: Constants.toolbarHeight)
        ))
        toolbar.layer.borderWidth = 1 / UIScreen.main.scale
        toolbar.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        toolbar.backgroundColor = UIColor.gray
        toolbar.tintColor = Asset.Colors.brightBlue.color
        
        let doneButton = UIBarButtonItem(
            title: L10n.Buttons.Done.title,
            style: .plain,
            target: self,
            action: #selector(done)
        )
        let doneAttr = [
            NSAttributedString.Key.foregroundColor: Asset.Colors.brightBlue.color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold) as Any
        ]
        doneButton.setTitleTextAttributes(doneAttr, for: .normal)

        let cancelButton = UIBarButtonItem(
            title: L10n.Buttons.Cancel.title,
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        let cancelAttr = [
            NSAttributedString.Key.foregroundColor: Asset.Colors.brightBlue.color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15) as Any
        ]
        cancelButton.setTitleTextAttributes(cancelAttr, for: .normal)
        
        let titleItem = UIBarButtonItem(
            title: L10n.Listing.List.sorting,
            style: .plain,
            target: nil,
            action: nil
        )
        let titleAttr = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium) as Any
        ]
        titleItem.setTitleTextAttributes(titleAttr, for: .normal)

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 16
        toolbar.setItems(
            [fixedSpace, cancelButton, flexSpace, titleItem, flexSpace, doneButton, fixedSpace],
            animated: true
        )
        addSubview(toolbar)
    }
    
    private func addPicker() {
        picker.frame = CGRect(
            origin: CGPoint(x: 0, y: Constants.toolbarHeight),
            size: CGSize(width: UIScreen.main.bounds.width, height: containerHeight - (Constants.toolbarHeight))
        )
        addSubview(picker)
    }
    
    @objc
    private func done() {
        let item = items[picker.selectedRow(inComponent: 0)]
        itemSelected?(item.id)
        hide()
    }
    
    @objc
    private func cancel() {
        hide()
    }
}

extension SortPickerView: UIPickerViewDataSource {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
}

extension SortPickerView: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].value
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

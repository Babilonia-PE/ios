//
//  InlinePropertiesView.swift
//  Babilonia
//
//  Created by Denis on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

final class InlinePropertiesView: UIView {

    enum LabelType {
        case small, large

        var font: UIFont {
            switch self {
            case .small: return FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
            case .large: return FontFamily.AvenirLTStd._65Medium.font(size: 14.0)
            }
        }
    }

    private let labelType: LabelType
    private var stackView: UIStackView!
    private var separators = [UIView]()
    private var labels = [UILabel]()
    
    // MARK: - lifecycle
    
    init(labelType: LabelType = .small) {
        self.labelType = labelType

        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with info: InlinePropertiesInfo) {
        layout(strings: info.strings, attributedStrings: info.attributedStrings)
        setupStringsView(color: info.color, isAttributed: !info.attributedStrings.isEmpty)
    }
    
    // MARK: - private
    
    private func layout() {
        stackView = UIStackView()
        addSubview(stackView)
        stackView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
    }
    
    private func layout(strings: [String], attributedStrings: [NSAttributedString]) {
        labels.forEach { $0.removeFromSuperview() }
        separators.forEach { $0.removeFromSuperview() }
        labels = []
        separators = []

        let isAttributed = !attributedStrings.isEmpty
        let labelCount = isAttributed ? attributedStrings.count : strings.count

        for index in 0..<labelCount {
            if index != 0 {
                let separator = UIView()
                stackView.addArrangedSubview(separator)
                separator.layout {
                    $0.width == 4.0
                    $0.height == 4.0
                }
                separators.append(separator)
            }

            let label = UILabel()
            if isAttributed {
                label.attributedText = attributedStrings[index]
            } else {
                label.text = strings[index]
            }
            stackView.addArrangedSubview(label)
            labels.append(label)

            label.layout {
                $0.height.equal(to: 16)
            }
        }
    }
    
    private func setupViews() {
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8.0
    }
    
    private func setupStringsView(color: UIColor, isAttributed: Bool) {
        separators.forEach {
            $0.layer.cornerRadius = 2.0
            $0.backgroundColor = Asset.Colors.pumice.color
        }

        guard !isAttributed else { return }
        labels.forEach {
            $0.textColor = color
            $0.font = labelType.font
        }
    }
    
}

//
//  CreateListingPageView.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class CreateListingPageView: UIView {
    
    enum State {
        case current, filled, empty
    }
    
    var didSelect: ControlEvent<Void> { return selectButton.rx.tap }
    
    private(set) var state: State!
    private(set) var title: String!
    private(set) var image: UIImage!
    
    private var backgroundView: UIView!
    private var imageView: UIImageView!
    private var sectionLabel: UILabel!
    private var selectButton: UIButton!
    
    private var labelWidthConstraing: NSLayoutConstraint!
    private var labelTrailingConstraing: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(state: State, title: String, image: UIImage) {
        self.state = state
        self.title = title
        self.image = image
        sectionLabel.text = title
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                switch state {
                case .current:
                    self.backgroundView.backgroundColor = Asset.Colors.hippieBlue.color
                    self.imageView.image = image.withRenderingMode(.alwaysTemplate)
                    self.imageView.tintColor = .white
                    self.labelWidthConstraing.priority = .selected
                    self.labelTrailingConstraing.constant = -16.0
                case .filled:
                    self.backgroundView.backgroundColor = Asset.Colors.aquaSpring.color
                    self.imageView.image = image.withRenderingMode(.alwaysTemplate)
                    self.imageView.tintColor = Asset.Colors.hippieBlue.color
                    self.labelWidthConstraing.priority = .deselected
                    self.labelTrailingConstraing.constant = -8.0
                case .empty:
                    self.backgroundView.backgroundColor = Asset.Colors.antiFlashWhite.color
                    self.imageView.image = image.withRenderingMode(.alwaysTemplate)
                    self.imageView.tintColor = Asset.Colors.osloGray.color
                    self.labelWidthConstraing.priority = .deselected
                    self.labelTrailingConstraing.constant = -8.0
                }
                // we need all nearest view's constraints to be recalculated here so calling `superview` here
                self.superview?.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    // MARK: - private
    
    private func layout() {
        backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.layout {
            $0.top == topAnchor + 16.0
            $0.bottom == bottomAnchor - 23.0
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 20.0
        
        imageView = UIImageView()
        addSubview(imageView)
        imageView.layout {
            $0.top == backgroundView.topAnchor + 8.0
            $0.bottom == backgroundView.bottomAnchor - 8.0
            $0.leading == backgroundView.leadingAnchor + 16.0
            $0.width == 24.0
            $0.height == 24.0
        }
        
        sectionLabel = UILabel()
        addSubview(sectionLabel)
        sectionLabel.layout {
            $0.top == backgroundView.topAnchor + 12.0
            $0.leading == imageView.trailingAnchor + 8.0
            labelTrailingConstraing = $0.trailing == backgroundView.trailingAnchor - 8.0
            $0.height == 16.0
            labelWidthConstraing = $0.width.equal(to: 0.0, priority: .deselected)
        }
        sectionLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        sectionLabel.textColor = .white
        sectionLabel.setContentHuggingPriority(UILayoutPriority(0.0), for: .horizontal)
        sectionLabel.setContentCompressionResistancePriority(UILayoutPriority(899.0), for: .horizontal)
        
        selectButton = UIButton()
        addSubview(selectButton)
        selectButton.layout {
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
    }
    
}

private extension UILayoutPriority {
    
    static var selected: UILayoutPriority { return UILayoutPriority(rawValue: 100.0) }
    static var deselected: UILayoutPriority { return UILayoutPriority(rawValue: 900.0) }
    
}

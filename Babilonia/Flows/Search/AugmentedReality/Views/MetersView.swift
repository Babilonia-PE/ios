//
//  MetersView.swift
//
//  Created by Vitaly Chernysh on 7/12/19.
//  Copyright © 2019 Vodolazkyi. All rights reserved.
//

import UIKit

final class MetersView: UIView {
    
    private var metersTitleLabel: UILabel!
    private var metersValueLabel: UILabel!
    
    private var isConstraintsSetUp = false
    private var isFirstLayout = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFirstLayout {
            addCornerRadius(6.0)
            isFirstLayout = false
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        guard !isConstraintsSetUp else { return }
        
        metersTitleLabel.layout {
            $0.bottom == bottomAnchor - 5.0
            $0.centerX == centerXAnchor
        }
        
        metersValueLabel.layout {
            $0.centerX == centerXAnchor
            $0.bottom == metersTitleLabel.topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
        
        isConstraintsSetUp = true
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        metersValueLabel = UILabel()
        metersValueLabel.textAlignment = .center
        metersValueLabel.font = FontFamily.AvenirLTStd._95Black.font(size: 24.0)
        metersValueLabel.textColor = Asset.Colors.vulcan.color
        metersValueLabel.text = "--"
        
        metersTitleLabel = UILabel()
        metersTitleLabel.textAlignment = .center
        metersTitleLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 10.0)
        metersTitleLabel.textColor = Asset.Colors.vulcan.color
        metersTitleLabel.text = L10n.Ar.MetersCounter.Many.title
        
        addSubview(metersTitleLabel)
        addSubview(metersValueLabel)
    }
    
}

extension MetersView: DistanceConfigurable {

    func applyDistance(_ distance: Double) {
        metersValueLabel.text = String(Int(distance))
        metersTitleLabel.text = metersTitle(by: distance)
    }

}

//
//  CustomAlertController.swift
//  Babilonia
//
//  Created by Rafael Miranda Salas on 13/12/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import UIKit

protocol CustomAlertDelegete {
    func aceptButton(
        reasonTextField: String,
        valueReason: String,
        infoListingId: ListingId?
    )
}

class CustomAlertViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var aceptButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    var delegate: CustomAlertDelegete? = nil
    var infoTitle: String?
    var infoDescription: String?
    var buttonDissmisLabel: String?
    var buttomAceptLabel: String?
    var valueReason: String?
    var listingId: ListingId?
    
    var strings: [String] = [L10n.Popups.UnpublishListingItems.babilonia,
                             L10n.Popups.UnpublishListingItems.portal,
                             L10n.Popups.UnpublishListingItems.social,
                             L10n.Popups.UnpublishListingItems.referrals,
                             L10n.Popups.UnpublishListingItems.sell]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCell()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func configureCell() {
        titleLabel.text = infoTitle
        descriptionLabel.text = infoDescription
        descriptionLabel.numberOfLines = 0
        dismissButton.setTitle(buttonDissmisLabel, for: .normal)
        aceptButton.setTitle(buttomAceptLabel, for: .normal)
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let firstIndexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: firstIndexPath, animated: true, scrollPosition: .none)
        tableView(tableView, didSelectRowAt: firstIndexPath)
        tableView.register(ItemReasonTableViewCell.nib(), forCellReuseIdentifier: ItemReasonTableViewCell.identifier)
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0
        alertView.frame.origin.y += 0
        
        UIView.animate(withDuration: 0.0) {
            self.alertView.alpha = 1.0
            self.alertView.frame.origin.y -= 0
        }
    }
    
    @IBAction func dissmisButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func aceptButton(_ sender: Any) {
        delegate?.aceptButton(
            reasonTextField: reasonTextField.text ?? "",
            valueReason: valueReason ?? "",
            infoListingId: listingId
        )
    }
    
}

extension CustomAlertViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch strings[indexPath.row] {
        case L10n.Popups.UnpublishListingItems.babilonia:
            valueReason = "babilonia"
        case L10n.Popups.UnpublishListingItems.portal:
            valueReason = "other"
        case L10n.Popups.UnpublishListingItems.social:
            valueReason = "rrss"
        case L10n.Popups.UnpublishListingItems.referrals:
            valueReason = "referal"
        case L10n.Popups.UnpublishListingItems.sell:
            valueReason = "unsold"
        default:
            valueReason = nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ItemReasonTableViewCell.identifier,
            for: indexPath
        ) as! ItemReasonTableViewCell
        cell.infoLabel.text = strings[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
}

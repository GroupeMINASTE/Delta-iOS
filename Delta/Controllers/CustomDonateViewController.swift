//
//  CustomDonateViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 12/07/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import DonateViewController
import DigiAnalytics

class CustomDonateViewController: DonateViewController, DonateViewControllerDelegate {

    override func viewDidLoad() {
        // Set strings
        title = "donate_title".localized()
        header = "donate_header".localized()
        footer = "donate_footer".localized()
        delegate = self
        
        // Add purchases
        add(identifier: "me.nathanfallet.delta.donation1")
        add(identifier: "me.nathanfallet.delta.donation2")
        add(identifier: "me.nathanfallet.delta.donation3")
        
        // Call super
        super.viewDidLoad()
        
        // Add close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close".localized(), style: .plain, target: self, action: #selector(close(_:)))
        
        // Send analytics
        DigiAnalytics.shared.send(path: "donate")
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        // Dismiss view controller
        dismiss(animated: true, completion: nil)
    }
    
    func donateViewController(_ controller: DonateViewController, didDonationSucceed donation: Donation) {
        let alert = UIAlertController(title: "donate_thanks".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func donateViewController(_ controller: DonateViewController, didDonationFailed donation: Donation) {
        print("Donation failed.")
    }

}

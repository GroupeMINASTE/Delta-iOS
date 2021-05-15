//
//  CloudDetailsTableViewCell.swift
//  Delta
//
//  Created by Nathan FALLET on 26/02/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import DigiAnalytics

class CloudDetailsTableViewCell: UITableViewCell {
    
    let bubble = UIView()
    let icon = UIImageView()
    let name = UILabel()
    let desc = UILabel()
    let notes = UILabel()
    let button = UIButton()
    let share = UIButton()
    var algorithm: APIAlgorithm?
    var onDevice: Algorithm?
    weak var delegate: CloudAlgorithmSelectionDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(bubble)
        contentView.addSubview(icon)
        contentView.addSubview(name)
        contentView.addSubview(desc)
        contentView.addSubview(notes)
        contentView.addSubview(button)
        contentView.addSubview(share)
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bubble.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        bubble.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        bubble.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        bubble.layer.cornerRadius = 10
        bubble.layer.masksToBounds = true
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10).isActive = true
        icon.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 10).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 44).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 44).isActive = true
        icon.layer.masksToBounds = true
        icon.layer.cornerRadius = 8
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10).isActive = true
        name.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
        name.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -10).isActive = true
        
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4).isActive = true
        desc.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
        desc.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -10).isActive = true
        desc.font = .systemFont(ofSize: 15)
        desc.textColor = .systemGray
        
        notes.translatesAutoresizingMaskIntoConstraints = false
        notes.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 15).isActive = true
        notes.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 10).isActive = true
        notes.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -10).isActive = true
        notes.font = .systemFont(ofSize: 15)
        notes.numberOfLines = 0
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(greaterThanOrEqualTo: notes.bottomAnchor, constant: 15).isActive = true
        button.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 10).isActive = true
        button.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10).isActive = true
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        share.translatesAutoresizingMaskIntoConstraints = false
        share.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
        share.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 10).isActive = true
        share.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -10).isActive = true
        share.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10).isActive = true
        share.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        share.layer.cornerRadius = 10
        share.layer.masksToBounds = true
        share.backgroundColor = .systemBlue
        share.setTitleColor(.white, for: .normal)
        share.setTitle("share".localized(), for: .normal)
        share.titleLabel?.font = .systemFont(ofSize: 15)
        share.addTarget(self, action: #selector(shareClicked(_:)), for: .touchUpInside)
        
        if #available(iOS 13.0, *) {
            bubble.backgroundColor = .secondarySystemGroupedBackground
        } else {
            bubble.backgroundColor = .white
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func with(algorithm: APIAlgorithm, onDevice: Algorithm?, delegate: CloudAlgorithmSelectionDelegate) -> CloudDetailsTableViewCell {
        // Set algorithms
        self.algorithm = algorithm
        self.onDevice = onDevice
        self.delegate = delegate
        
        // Set views
        self.name.text = algorithm.name
        self.desc.text = algorithm.owner?.name
        self.notes.text = algorithm.notes ?? "cloud_no_notes".localized()
        self.icon.image = algorithm.icon?.icon.toIcon()
        self.icon.backgroundColor = algorithm.icon?.color.toColor()
        
        // Calculate button
        self.button.setTitle(getButton().localized(), for: .normal)
        
        return self
    }
    
    func getButton() -> String {
        if let onDevice = onDevice, let last_update = algorithm?.last_update?.toDate() {
            // Compare last update date
            let compare = onDevice.last_update.compare(last_update)
            if compare == .orderedSame {
                // Open
                return "open"
            }
            
            // Update
            return "update"
        }
        
        // Download
        return "download"
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        // Get button and check what to do
        let button = getButton()
        if button == "download" || button == "update" {
            DigiAnalytics.shared.send(path: "cloud/download/\(algorithm?.id ?? -1)")
            open(algorithm: download())
        } else {
            open(algorithm: onDevice)
        }
    }
    
    @objc func shareClicked(_ sender: UIButton) {
        // Get algorithm url
        if let id = algorithm?.id, let url = URL(string: "https://www.delta-algorithms.com/algorithm/\(id)"), let controller = delegate as? UIViewController {
            // Create the controller
            let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // Set source (for iPad)
            shareVC.popoverPresentationController?.sourceView = share
            shareVC.popoverPresentationController?.sourceRect = share.bounds
            
            // Show the activity controller
            controller.present(shareVC, animated: true, completion: nil)
            DigiAnalytics.shared.send(path: "cloud/share/\(id)")
        }
    }
    
    func download() -> Algorithm? {
        // Save the algorithm on the device
        return algorithm?.saveToDatabase()
    }
    
    func open(algorithm: Algorithm?) {
        if let algorithm = algorithm {
            // Open it
            delegate?.open(algorithm: algorithm)
        }
    }

}

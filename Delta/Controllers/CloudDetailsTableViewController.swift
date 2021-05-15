//
//  CloudDetailsTableViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 26/02/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import APIRequest
import DigiAnalytics

class CloudDetailsTableViewController: UITableViewController, CloudAlgorithmSelectionDelegate, StatusContainerDelegate {
    
    weak var delegate: CloudAlgorithmOpenDelegate?
    var statusLabel = UILabel()
    var status: APIResponseStatus = .ok
    var algorithm: APIAlgorithm?
    var onDevice: Algorithm?
    var preview: [EditorLine]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add status label
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor).isActive = true
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true
        
        // No separator
        tableView.separatorStyle = .none

        // Register cells
        tableView.register(CloudDetailsTableViewCell.self, forCellReuseIdentifier: "detailsCell")
        tableView.register(EditorPreviewTableViewCell.self, forCellReuseIdentifier: "editorLockedCell")
        
        // Make cells auto sizing
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadContent(_:)), for: .valueChanged)
    }
    
    @objc func reloadContent(_ sender: UIRefreshControl) {
        // Reload algorithms
        refreshData()
    }
    
    func selectAlgorithm(_ algorithm: APIAlgorithm?) {
        // Clear algorithm
        self.algorithm = nil
        self.preview = nil
        
        // Set status to loading
        self.status = .loading
        
        // Update tableView
        self.reloadData(withStatus: status)
        
        // Fetch data
        algorithm?.fetchMissingData() { data, status in
            // Update status
            self.status = status
            
            // Check data
            if let data = data {
                // Set algorithm
                self.algorithm = data
                
                // Set preview
                self.preview = data.toAlgorithm().toEditorLines().filter { line in
                    return line.category != .add
                }
                
                // Get it on device if exists
                self.onDevice = Database.current.getAlgorithm(id_remote: data.id ?? -1)
                
                // Update navigation bar
                self.navigationItem.title = data.name
            }
            
            // Update tableView
            self.reloadData(withStatus: status)
        }
        
        // Send analytics
        if let algorithm = algorithm {
            DigiAnalytics.shared.send(path: "cloud/view/\(algorithm.id ?? -1)")
        }
    }
    
    func refreshData() {
        // Reload everything
        selectAlgorithm(self.algorithm)
    }
    
    func open(algorithm: Algorithm) {
        // Use delegate to close Cloud and open algorithm
        delegate?.closeCloudAndOpen(algorithm: algorithm)
    }
    
    func getStatusLabel() -> UILabel {
        return statusLabel
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return algorithm != nil ? 2 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : preview?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "cloud_details".localized() : "cloud_preview".localized()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let algorithm = algorithm {
            // Check section
            if indexPath.section == 0 {
                // Create cell
                return (tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as! CloudDetailsTableViewCell).with(algorithm: algorithm, onDevice: onDevice, delegate: self)
            } else if let line = preview?[indexPath.row] {
                // Create cell
                return (tableView.dequeueReusableCell(withIdentifier: "editorLockedCell", for: indexPath) as! EditorPreviewTableViewCell).with(line: line)
            }
        }
        
        fatalError("Data not found")
    }

}

protocol CloudAlgorithmOpenDelegate: AnyObject {
    
    func closeCloudAndOpen(algorithm: Algorithm)
    
}

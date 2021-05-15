//
//  CloudSettingsTableViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 13/07/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import DigiAnalytics

class CloudSettingsTableViewController: UITableViewController {
    
    let algorithm: Algorithm
    let completionHandler: (Algorithm) -> ()
    
    var loaded = false
    var `public`: Bool?
    var notes: String?
    
    init(algorithm: Algorithm, completionHandler: @escaping (Algorithm) -> ()) {
        self.algorithm = algorithm
        self.completionHandler = completionHandler
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar
        navigationItem.title = "cloud_settings_title".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close".localized(), style: .plain, target: self, action: #selector(close(_:)))
        
        // Register cells
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(RightDetailTableViewCell.self, forCellReuseIdentifier: "rightDetailCell")
        
        // Make cells auto sizing
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        // Fetch metadatas
        fetchMetadatas()
        
        // Send analytics
        DigiAnalytics.shared.send(path: "cloud/settings")
    }
    
    func fetchMetadatas() {
        // No more loaded (in case of reset needed)
        loaded = false
        
        // Call API
        APIAlgorithm(id: algorithm.remote_id, name: nil, owner: nil, last_update: nil, lines: nil, notes: nil, icon: nil, public: nil).fetchMissingData { data, status in
            // Check response
            if let data = data, status == .ok {
                // Update data
                self.public = data.public
                self.notes = data.notes
                self.loaded = true
            }
            
            // Refresh table view
            self.tableView.reloadData()
        }
    }
    
    func sendMetadatas() {
        // Create an alert (for progress)
        let alert = UIAlertController(title: "status_uploading".localized(), message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        // Send analytics
        DigiAnalytics.shared.send(path: "cloud/upload")
        
        // Start uploading
        algorithm.toAPIAlgorithm(public: `public` ?? false, notes: notes ?? "").upload { data, status in
            // Remove alert
            alert.dismiss(animated: true, completion: nil)
            
            // Check data
            if let data = data, status == .ok || status == .created {
                // Transform returned data
                self.algorithm.remote_id = data.id
                self.public = data.public
                self.notes = data.notes
                self.loaded = true
                
                // Send back new data
                self.completionHandler(self.algorithm)
            }
            
            // Refresh table view
            self.tableView.reloadData()
        }
    }
    
    func removeFromCloud() {
        // Create an alert (for progress)
        let alert = UIAlertController(title: "status_deleting".localized(), message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        // Send analytics
        DigiAnalytics.shared.send(path: "cloud/delete")
        
        // Start deleting
        algorithm.toAPIAlgorithm().delete { data, status in
            // Remove alert
            alert.dismiss(animated: true, completion: nil)
            
            // Check data
            if status == .ok {
                // Remove remote id
                self.algorithm.remote_id = nil
                self.loaded = false
                
                // Send back new data
                self.completionHandler(self.algorithm)
            }
            
            // Refresh table view
            self.tableView.reloadData()
        }
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        // Dismiss view controller
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return algorithm.remote_id != nil ? 3 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "cloud_settings_sync_title".localized() : section == 1 ? "cloud_settings_public_title".localized() : "cloud_settings_other_title".localized()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Visibility
        if indexPath.section == 1 {
            return (tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell).with(text: "cloud_settings_public".localized(), enabled: loaded ? `public` : nil, onChange: publicChanged)
        }
        
        // Other
        if indexPath.section == 2 {
            // Notes
            if indexPath.row == 0 {
                return (tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath) as! RightDetailTableViewCell).with(left: "cloud_settings_notes".localized(), right: loaded ? notes ?? "cloud_no_notes".localized() : "loading".localized(), accessory: .disclosureIndicator)
            }
        }
        
        // Cell to enable/disable cloud sync
        return (tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell).with(text: "cloud_settings_sync".localized(), enabled: algorithm.remote_id != nil, onChange: syncChanged)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check that content is loaded before
        guard loaded else { return }
        
        // Other
        if indexPath.section == 2 {
            // Notes
            if indexPath.row == 0 {
                // Open notes editor
                changeNotes()
            }
        }
    }
    
    // MARK: - Handlers
    
    func syncChanged(enabled: Bool) {
        // Check if switch is enabled
        if enabled {
            // Upload
            sendMetadatas()
        } else {
            // Remove from cloud
            removeFromCloud()
        }
    }
    
    func publicChanged(enabled: Bool) {
        // Update value
        self.public = enabled
        
        // Send metadatas
        self.sendMetadatas()
    }
    
    func changeNotes() {
        // Create an alert with a text field
        let editor = UIAlertController(title: "cloud_settings_notes_title".localized(), message: nil, preferredStyle: .alert)
        editor.addTextField { field in
            field.text = self.notes
        }
        editor.addAction(UIAlertAction(title: "save".localized(), style: .default, handler: { _ in
            // Update value
            self.notes = editor.textFields?.first?.text ?? ""
            
            // Send metadatas
            self.sendMetadatas()
        }))
        editor.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        present(editor, animated: true, completion: nil)
    }

}

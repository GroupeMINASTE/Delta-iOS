//
//  HomeTableViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 07/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import UIKit
import StoreKit

class HomeTableViewController: UITableViewController, AlgorithmsChangedDelegate {
    
    weak var delegate: AlgorithmSelectionDelegate?
    var myalgorithms = [Algorithm]()
    var downloads = [Algorithm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "name".localized()
        
        // Register cells
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "homeCell")
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: "labelCell")
        
        // Load algorithms
        loadAlgorithms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    func loadAlgorithms() {
        // Clear previous data
        myalgorithms = []
        downloads = []
        
        // Retrieve algorithms from database
        let algorithms = Database.current.getAlgorithms()
        
        // Iterate them
        for algorithm in algorithms {
            // Check if owned or downloaded
            if algorithm.owner {
                // Add to My algorithms
                myalgorithms.append(algorithm)
            } else {
                // Add to Downloads
                downloads.append(algorithm)
            }
        }
        
        // If downloads are empty, add defaults
        if downloads.isEmpty {
            // Download default downloads
            for algorithm in Algorithm.defaults {
                // Save it locally
                let algorithm = Database.current.addAlgorithm(algorithm)
                
                // Add to Downloads
                downloads.append(algorithm)
            }
        }
        
        // Update tableView
        tableView.reloadData()
        
        // Check for update for all algorithms
        for algorithm in myalgorithms + downloads {
            // Check for update
            algorithm.checkForUpdate() { updatedAlgorithm in
                self.algorithmChanged(updatedAlgorithm: updatedAlgorithm)
            }
        }
    }
    
    func algorithmsChanged() {
        // Upload algorithm list
        loadAlgorithms()
    }
    
    func algorithmChanged(updatedAlgorithm: Algorithm) {
        for i in 0 ..< self.myalgorithms.count {
            if (self.myalgorithms[i].local_id == updatedAlgorithm.local_id && self.myalgorithms[i].local_id != 0) || (self.myalgorithms[i].remote_id == updatedAlgorithm.remote_id && self.myalgorithms[i].remote_id != 0) {
                // Replace
                self.myalgorithms.remove(at: i)
                self.myalgorithms.insert(updatedAlgorithm, at: i)
                
                // Update tableView
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
                self.tableView.endUpdates()
            }
        }
        for i in 0 ..< self.downloads.count {
            if (self.downloads[i].local_id == updatedAlgorithm.local_id && self.downloads[i].local_id != 0) || (self.downloads[i].remote_id == updatedAlgorithm.remote_id && self.downloads[i].remote_id != 0) {
                // Replace
                self.downloads.remove(at: i)
                self.downloads.insert(updatedAlgorithm, at: i)
                
                // Update tableView
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 2)], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }

    // TableView management

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 :
            section == 1 ? myalgorithms.count == 0 ? 1 : myalgorithms.count :
            section == 2 ? downloads.count == 0 ? 1 : downloads.count :
            section == 3 ? 3 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "new_algorithm".localized() : section == 1 ? "myalgorithms".localized() : section == 2 ? "downloads".localized() : section == 3 ?  "about".localized() : "partner_apps".localized()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check for section
        if indexPath.section == 0 {
            // Create new cell
            return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: indexPath.row == 0 ? "new_algorithm".localized() : "download_algorithm".localized(), accessory: .disclosureIndicator)
        } else if indexPath.section == 1 {
            // Check for empty section
            if myalgorithms.count == 0 {
                return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: "no_algorithm".localized(), accessory: .none)
            }
            
            // Get algorithm
            let algorithm = myalgorithms[indexPath.row]
            
            // Create cell
            return (tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell).with(algorithm: algorithm)
        } else if indexPath.section == 2 {
            // Check for empty section
            if downloads.count == 0 {
                return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: "no_algorithm".localized(), accessory: .none)
            }
            
            // Get algorithm
            let algorithm = downloads[indexPath.row]
            
            // Create cell
            return (tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell).with(algorithm: algorithm)
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                // About
                return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: "about".localized(), accessory: .disclosureIndicator)
            } else if indexPath.row == 1 {
                // Help and documentation
                return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: "help".localized(), accessory: .disclosureIndicator)
            } else if indexPath.row == 2 {
                // Follow us on Twitter
                return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: "follow_twitter".localized(), accessory: .disclosureIndicator)
            }
        } else {
            if indexPath.row == 0 {
                // SchoolAssistant
                return (tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell).with(name: "School Assistant", desc: "schoolassistant_desc".localized(), icon: UIImage(named: "SchoolAssistant"))
            }
        }
        
        fatalError("Unknown cell!")
    }
    
    // Navigation management
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check for section
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // Create an editor
                let editor = EditorTableViewController(algorithm: nil) { newAlgorithm in
                    // Update with new algorithm
                    self.loadAlgorithms()
                }
                
                // Create the navigation controller
                let navigationController = UINavigationController(rootViewController: editor)
                navigationController.modalPresentationStyle = .fullScreen
                
                // Show it
                present(navigationController, animated: true, completion: nil)
            } else {
                // Open the cloud
                let cloudVC = CloudSplitViewController()
                cloudVC.modalPresentationStyle = .fullScreen
                cloudVC.changedDelegate = self
                cloudVC.selectionDelegate = delegate
                
                // Show it
                present(cloudVC, animated: true, completion: nil)
            }
        } else if indexPath.section == 1 {
            // Check for empty section
            if myalgorithms.count == 0 {
                return
            }
            
            // Get selected algorithm
            let algorithm = myalgorithms[indexPath.row]
            
            // Update the delegate
            delegate?.selectAlgorithm(algorithm)
            
            // Show view controller
            if let algorithmVC = delegate as? AlgorithmTableViewController, let algorithmNavigation = algorithmVC.navigationController {
                splitViewController?.showDetailViewController(algorithmNavigation, sender: nil)
            }
        } else if indexPath.section == 2 {
            // Check for empty section
            if downloads.count == 0 {
                return
            }
            
            // Get selected algorithm
            let algorithm = downloads[indexPath.row]
            
            // Update the delegate
            delegate?.selectAlgorithm(algorithm)
            
            // Show view controller
            if let algorithmVC = delegate as? AlgorithmTableViewController, let algorithmNavigation = algorithmVC.navigationController {
                splitViewController?.showDetailViewController(algorithmNavigation, sender: nil)
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                // About
                let alert = UIAlertController(title: "about".localized(), message: "about_text".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                // Help and documentation
                if let url = URL(string: "https://www.delta-math-helper.com") {
                    UIApplication.shared.open(url)
                }
            } else if indexPath.row == 2 {
                // Follow us on Twitter
                if let url = URL(string: "https://twitter.com/DeltaMathHelper") {
                    UIApplication.shared.open(url)
                }
            }
        } else {
            if indexPath.row == 0 {
                // SchoolAssistant
                if let url = URL(string: isRunningOnMac() ? "https://apps.apple.com/app/school-assistant-planner/id1489319800" : "https://apps.apple.com/app/school-assistant-planner/id1465687472") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // Editing support for custom algorithms

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 || indexPath.section == 2
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "delete".localized()) { (action, view, completionHandler) in
            // Define algorithm
            let algorithm: Algorithm
            
            // Check for section
            if indexPath.section == 1 {
                // Get selected algorithm
                algorithm = self.myalgorithms[indexPath.row]
            } else {
                // Get selected algorithm
                algorithm = self.downloads[indexPath.row]
            }
            
            // Delete it from database
            Database.current.deleteAlgorithm(algorithm)
            
            // Update without algorithm
            self.loadAlgorithms()
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal, title: "edit".localized()) { (action, view, completionHandler) in
            // Define algorithm
            let algorithm: Algorithm
            
            // Check for section
            if indexPath.section == 1 {
                // Get selected algorithm
                algorithm = self.myalgorithms[indexPath.row]
            } else {
                // Get selected algorithm
                algorithm = self.downloads[indexPath.row]
            }
            
            // Create an editor
            let editor = EditorTableViewController(algorithm: Database.current.getAlgorithm(id_local: algorithm.local_id)) { newAlgorithm in
                // Update with new algorithm
                self.loadAlgorithms()
            }
            
            // Create the navigation controller
            let navigationController = UINavigationController(rootViewController: editor)
            navigationController.modalPresentationStyle = .fullScreen
            
            // Show it
            self.present(navigationController, animated: true, completion: nil)
            completionHandler(true)
        }
        edit.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func isRunningOnMac() -> Bool {
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return false
        #endif
    }

}

protocol AlgorithmSelectionDelegate: class {
    
    func selectAlgorithm(_ algorithm: Algorithm?)
    
}

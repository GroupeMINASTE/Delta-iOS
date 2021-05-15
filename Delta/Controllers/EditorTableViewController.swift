//
//  EditorTableViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 20/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import UIKit
import DigiAnalytics

class EditorTableViewController: UITableViewController, EditorLineChangedDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    let algorithm: Algorithm
    let completionHandler: (Algorithm) -> ()
    
    init(algorithm: Algorithm?, completionHandler: @escaping (Algorithm) -> ()) {
        self.algorithm = algorithm?.clone() ?? Algorithm(local_id: 0, remote_id: nil, owner: true, name: "new_algorithm".localized(), last_update: Date(), icon: AlgorithmIcon(), root: RootAction([]))
        self.completionHandler = completionHandler
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar
        navigationItem.title = "editor".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel".localized(), style: .plain, target: self, action: #selector(close(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized(), style: .plain, target: self, action: #selector(save(_:)))
        
        // No separator
        tableView.separatorStyle = .none
        
        // Register cells
        tableView.register(EditorTableViewCell.self, forCellReuseIdentifier: "editorCell")
        tableView.register(EditorAddTableViewCell.self, forCellReuseIdentifier: "editorAddCell")
        
        // Make cells auto sizing
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        // Support for drag and drop
        if #available(iOS 11, *) {
            tableView.dragInteractionEnabled = true
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        // Send analytics
        DigiAnalytics.shared.send(path: "algorithm/edit")
    }
    
    func editorLineChanged(_ line: EditorLine?, at index: Int) {
        // Get line
        if let line = line {
            // Update the line into algorithm
            algorithm.update(line: line, at: index)
        }
    }
    
    func editorLineAdded(_ action: Action, at index: Int) {
        // Add the line into algorithm
        let range = algorithm.insert(action: action, at: index)
        
        // Insert new rows
        tableView.beginUpdates()
        tableView.insertRows(at: range.map{ IndexPath(row: $0, section: 1) }, with: .automatic)
        tableView.endUpdates()
        
        // Refresh lines
        refreshLines()
    }
    
    func editorLineDeleted(_ line: EditorLine?, at index: Int) {
        // Delete the line into algorithm
        let range = algorithm.delete(at: index)
        
        // Delete old rows
        tableView.beginUpdates()
        tableView.deleteRows(at: range.map{ IndexPath(row: $0, section: 1) }, with: .automatic)
        tableView.endUpdates()
        
        // Refresh lines
        refreshLines()
    }
    
    func editorLineMoved(from fromIndex: Int, to toIndex: Int) {
        // Delete the line into algorithm
        let (range, newRange) = algorithm.move(from: fromIndex, to: toIndex)
        
        // Delete old rows
        tableView.beginUpdates()
        tableView.deleteRows(at: range.map{ IndexPath(row: $0, section: 1) }, with: .automatic)
        tableView.insertRows(at: newRange.map{ IndexPath(row: $0, section: 1) }, with: .automatic)
        tableView.endUpdates()
        
        // Refresh lines
        refreshLines()
    }
    
    func refreshLines() {
        // Refresh lines
        let lines = algorithm.editorLinesCount()
        for i in 0 ..< lines {
            // Get cell (classic line)
            if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as? EditorTableViewCell {
                // Update index
                cell.index = i
            }
            
            // Get cell (add)
            if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as? EditorAddTableViewCell {
                // Update index
                cell.index = i
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? algorithm.settingsCount() : algorithm.editorLinesCount()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "settings".localized() : "instructions".localized()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get editor line
        let line = indexPath.section == 0 ? algorithm.getSettings()[indexPath.row] : algorithm.toEditorLines()[indexPath.row]
        
        // Check if add
        if line.category == .add {
            // Return cell
            return (tableView.dequeueReusableCell(withIdentifier: "editorAddCell", for: indexPath) as! EditorAddTableViewCell).with(line: line, delegate: self, at: indexPath.row)
        }
        
        // Return cell
        return (tableView.dequeueReusableCell(withIdentifier: "editorCell", for: indexPath) as! EditorTableViewCell).with(line: line, delegate: self, at: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get editor line
        let line = indexPath.section == 0 ? algorithm.getSettings()[indexPath.row] : algorithm.toEditorLines()[indexPath.row]
        
        // Check if icon
        if line.format == "settings_icon" {
            // Open icon editor
            present(UINavigationController(rootViewController: IconEditorTableViewController(icon: algorithm.icon, completionHandler: { icon in
                self.algorithm.icon = icon
            })), animated: true, completion: nil)
        } else if line.format == "settings_cloud" {
            // Check if user is connected
            if Account.current.access_token != nil {
                // Open cloud sharing settings
                present(UINavigationController(rootViewController: CloudSettingsTableViewController(algorithm: algorithm, completionHandler: { algorithm in
                    // Take new algorithm remote id
                    self.algorithm.remote_id = algorithm.remote_id
                    
                    // Background processing
                    DispatchQueue.global(qos: .background).async {
                        // Update last update
                        self.algorithm.last_update = Date()
                        
                        // Save algorithm to database
                        let newAlgorithm = Database.current.updateAlgorithm(self.algorithm)
                        
                        // UI call
                        DispatchQueue.main.async {
                            // Call completion handler
                            self.completionHandler(newAlgorithm)
                        }
                    }
                })), animated: true, completion: nil)
            } else {
                // User not logged in
                let error = UIAlertController(title: "settings_cloud_error".localized(), message: nil, preferredStyle: .alert)
                error.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
                self.present(error, animated: true, completion: nil)
            }
        }
    }

    @objc func close(_ sender: UIBarButtonItem) {
        // Dismiss view controller
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save(_ sender: UIBarButtonItem) {
        // Disable button while saving
        sender.isEnabled = false
        
        // Async call
        DispatchQueue.global(qos: .background).async {
            // Update last update
            self.algorithm.last_update = Date()
            
            // Save algorithm to database
            let newAlgorithm = Database.current.updateAlgorithm(self.algorithm)
            
            // UI call
            DispatchQueue.main.async {
                // Call completion handler
                self.completionHandler(newAlgorithm)
                
                // Dismiss view controller
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Get editor line
        let line = indexPath.section == 0 ? algorithm.getSettings()[indexPath.row] : algorithm.toEditorLines()[indexPath.row]
        
        return line.category != .settings && line.category != .add
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // Get editor line
        let line = indexPath.section == 0 ? algorithm.getSettings()[indexPath.row] : algorithm.toEditorLines()[indexPath.row]
        
        // Disable drag for settings, add buttons, else, and end lines
        if !line.movable {
            return []
        }
        
        // Create a provider
        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: "fr.zabricraft.Delta.ActionMoveRequest", visibility: .all) { completion in
            var index = indexPath.row
            completion(Data(bytes: &index, count: MemoryLayout.size(ofValue: index)), nil)
            return nil
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        session.hasItemsConforming(toTypeIdentifiers: ["fr.zabricraft.Delta.ActionMoveRequest"]) && session.items.count == 1
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        // Check if data can be decoded
        if coordinator.session.hasItemsConforming(toTypeIdentifiers: ["fr.zabricraft.Delta.ActionMoveRequest"]) {
            // Get item
            for item in coordinator.session.items {
                // Load the line
                item.itemProvider.loadDataRepresentation(forTypeIdentifier: "fr.zabricraft.Delta.ActionMoveRequest") { data, _ in
                    if let index = data?.withUnsafeBytes({ $0.load(as: Int.self) }), let destination = coordinator.destinationIndexPath, destination.section == 1 {
                        // Remove original line to move it to destination
                        DispatchQueue.main.sync {
                            self.editorLineMoved(from: index, to: destination.row)
                        }
                    }
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return session.items.count > 1 ? UITableViewDropProposal(operation: .cancel) : UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let previewParameters = UIDragPreviewParameters()
        
        if let cell = tableView.cellForRow(at: indexPath) as? EditorTableViewCell {
            let path = UIBezierPath(roundedRect: cell.bubble.frame, cornerRadius: 10.0)
            previewParameters.visiblePath = path
            previewParameters.backgroundColor = .clear
        }
        
        return previewParameters
    }
    
}

protocol EditorLineChangedDelegate: AnyObject {
    
    func editorLineChanged(_ line: EditorLine?, at index: Int)
    func editorLineAdded(_ action: Action, at index: Int)
    func editorLineDeleted(_ line: EditorLine?, at index: Int)
    
}

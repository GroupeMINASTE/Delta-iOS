//
//  ActionSelectionTableViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 22/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import UIKit

class ActionSelectionTableViewController: UITableViewController {
    
    var completionHandler: (Action) -> ()
    
    init(completionHandler: @escaping (Action) -> ()) {
        self.completionHandler = completionHandler
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar
        navigationItem.title = "action_selector".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel".localized(), style: .plain, target: self, action: #selector(close(_:)))
        
        // No separator
        tableView.separatorStyle = .none
        
        // Register cells
        tableView.register(EditorPreviewTableViewCell.self, forCellReuseIdentifier: "editorLockedCell")
        
        // Make cells auto sizing
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return EditorLineCategory.values.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditorLineCategory.values[section].catalog().count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "category_\(EditorLineCategory.values[section].rawValue)".localized()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get first line
        if let line = EditorLineCategory.values[indexPath.section].catalog()[indexPath.row].toEditorLines().first {
            // Return cell
            return (tableView.dequeueReusableCell(withIdentifier: "editorLockedCell", for: indexPath) as! EditorPreviewTableViewCell).with(line: line)
        }
        
        fatalError("Unknown cell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get action
        let action = EditorLineCategory.values[indexPath.section].catalog()[indexPath.row]
        
        // Call completion handler
        completionHandler(action)
        
        // Dismiss view controller
        dismiss(animated: true, completion: nil)
    }

    @objc func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}

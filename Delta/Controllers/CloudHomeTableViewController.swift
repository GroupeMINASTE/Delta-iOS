//
//  CloudHomeTableViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 26/02/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import APIRequest
import DigiAnalytics

class CloudHomeTableViewController: UITableViewController, UISearchBarDelegate, StatusContainerDelegate {
    
    weak var delegate: CloudAlgorithmSelectionDelegate?
    var statusLabel = UILabel()
    var algorithms = [APIAlgorithm]()
    var loading = false
    var hasMore = true
    var search = ""
    var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.title = "cloud".localized()
        
        // Add status label
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor).isActive = true
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true
        
        // Register cells
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "homeCell")
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "loadingCell")
        
        // Make cells auto sizing
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        // Search controller
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        if #available(iOS 11, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadContent(_:)), for: .valueChanged)
        
        // Load algorithms
        loadAlgorithms(reset: true)
        
        // Send analytics
        DigiAnalytics.shared.send(path: "cloud/home")
    }
    
    @objc func reloadContent(_ sender: UIRefreshControl) {
        // Reload algorithms
        loadAlgorithms(reset: true)
    }
    
    func loadAlgorithms(reset: Bool = false) {
        // Reset content if needed
        if reset {
            self.hasMore = true
        }
        
        // Check that it is not already loading
        guard !loading && hasMore else { return }
        loading = true
        
        // Load algorithms from API
        APIRequest("GET", path: "/algorithm/search.php").with(name: "search", value: search).with(name: "start", value: reset ? 0 : algorithms.count).execute([APIAlgorithm].self) { data, status in
            // Reset if needed
            if reset {
                self.algorithms = []
            }
            
            // Check data
            if let data = data {
                // Check content size
                if !data.isEmpty {
                    // Update data
                    self.algorithms.append(contentsOf: data)
                } else {
                    // No more content
                    self.hasMore = false
                }
            }
            
            // No more loading
            self.loading = false
            
            // Refresh the view
            self.reloadData(withStatus: status)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Update search
        search = searchBar.text ?? ""
        
        // Reload algorithms
        loadAlgorithms(reset: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Update search
        search = ""
        
        // Reload algorithms
        loadAlgorithms(reset: true)
    }
    
    func getStatusLabel() -> UILabel {
        return statusLabel
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? algorithms.count : hasMore ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "cloud_algorithms".localized() : nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Loading cell
        if indexPath.section != 0 {
            return (tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingTableViewCell).with()
        }
        
        // Get algorithm
        let algorithm = algorithms[indexPath.row]
        
        // Create cell
        return (tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell).with(algorithm: algorithm)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Loading cell
        guard indexPath.section != 0 else { return }
        
        // Load more content
        loadAlgorithms()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check that cell is not a loading cell
        guard indexPath.section == 0 else { return }
        
        // Get selected algorithm
        let algorithm = algorithms[indexPath.row]
        
        // Update the delegate
        delegate?.selectAlgorithm(algorithm)
        
        // Show view controller
        if let algorithmVC = delegate as? CloudDetailsTableViewController, let algorithmNavigation = algorithmVC.navigationController {
            splitViewController?.showDetailViewController(algorithmNavigation, sender: nil)
        }
    }

}

protocol CloudAlgorithmSelectionDelegate: AnyObject {
    
    func selectAlgorithm(_ algorithm: APIAlgorithm?)
    
    func refreshData()
    
    func open(algorithm: Algorithm)
    
}

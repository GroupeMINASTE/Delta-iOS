//
//  Database.swift
//  Delta
//
//  Created by Nathan FALLET on 23/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation
import SQLite
import StoreKit

class Database {
    
    // Static instance
    static let current = Database()
    
    // Properties
    private var db: Connection?
    let algorithms = Table("algorithms")
    let local_id = Expression<Int64>("local_id")
    let remote_id = Expression<Int64?>("remote_id")
    let name = Expression<String>("name")
    let lines = Expression<String>("lines")
    let owner = Expression<Bool>("owner")
    let last_update = Expression<Date>("last_update")
    let icon = Expression<String>("icon")
    let color = Expression<String>("color")
    
    // Initialize
    init() {
        do {
            // Get database path
            if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                // If delta-math-helper.sqlite3 exists, rename it
                if FileManager.default.fileExists(atPath: "\(path)/delta-math-helper.sqlite3") {
                    try FileManager.default.moveItem(atPath: "\(path)/delta-math-helper.sqlite3", toPath: "\(path)/delta-algorithms.sqlite3")
                }
                
                // Connect to database
                db = try Connection("\(path)/delta-algorithms.sqlite3")
                
                // Initialize tables
                try db?.run(algorithms.create(ifNotExists: true) { table in
                    table.column(local_id, primaryKey: .autoincrement)
                    table.column(remote_id)
                    table.column(name)
                    table.column(lines)
                    table.column(owner)
                    table.column(last_update)
                    table.column(icon, defaultValue: AlgorithmIcon.defaultIcon)
                    table.column(color, defaultValue: AlgorithmIcon.defaultColor)
                })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Update database
    func updateDatabase(build_number: Int) {
        if build_number < 24 {
            // Add icon and color to table
            do {
                try db?.run(algorithms.addColumn(icon, defaultValue: AlgorithmIcon.defaultIcon))
                try db?.run(algorithms.addColumn(color, defaultValue: AlgorithmIcon.defaultColor))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // Get algorithms
    func getAlgorithms() -> [Algorithm] {
        // Initialize an array
        var list = [Algorithm]()
        
        do {
            // Get algorithms data
            if let result = try db?.prepare(algorithms.order(last_update.desc)) {
                // Iterate data
                for line in result {
                    // Create algorithm in list
                    list.append(AlgorithmParser(try line.get(local_id), remote_id: try line.get(remote_id), owned: try line.get(owner), named: try line.get(name), last_update: try line.get(last_update), icon: AlgorithmIcon(icon: try line.get(icon), color: try line.get(color)), with: try line.get(lines)).execute())
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // Return found algorithms
        return list
    }
    
    // Get algorithm by id
    func getAlgorithm(id_local: Int64 = -1, id_remote: Int64 = -1) -> Algorithm? {
        do {
            // Get algorithm data
            if let result = try db?.prepare(algorithms.filter(local_id == id_local || remote_id == id_remote)) {
                // Iterate data
                for line in result {
                    // Create the algorithm
                    return AlgorithmParser(try line.get(local_id), remote_id: try line.get(remote_id), owned: try line.get(owner), named: try line.get(name), last_update: try line.get(last_update), icon: AlgorithmIcon(icon: try line.get(icon), color: try line.get(color)), with: try line.get(lines)).execute()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // No algorithm found
        return nil
    }
    
    // Add an algorithm into database
    func addAlgorithm(_ algorithm: Algorithm) -> Algorithm {
        do {
            // Insert data
            let id = try db?.run(algorithms.insert(remote_id <- algorithm.remote_id, name <- algorithm.name, lines <- algorithm.toString(), owner <- algorithm.owner, last_update <- algorithm.last_update, icon <- algorithm.icon.icon, color <- algorithm.icon.color)) ?? 0
            
            // Update id
            algorithm.local_id = id
        } catch {
            print(error.localizedDescription)
        }
        
        // Check number of saves to ask for a review
        checkForReview()
        
        // Return algorithm
        return algorithm
    }
    
    // Update an algorithm
    func updateAlgorithm(_ algorithm: Algorithm) -> Algorithm {
        do {
            // If id is 0
            if algorithm.local_id == 0 {
                // Insert the algorithm
                return addAlgorithm(algorithm)
            }
            
            // Get line
            let line = algorithms.filter(local_id == algorithm.local_id)
            
            // Update data
            try db?.run(line.update(remote_id <- algorithm.remote_id, name <- algorithm.name, lines <- algorithm.toString(), owner <- algorithm.owner, last_update <- algorithm.last_update, icon <- algorithm.icon.icon, color <- algorithm.icon.color))
        } catch {
            print(error.localizedDescription)
        }
        
        // Check number of saves to ask for a review
        checkForReview()
        
        // Return algorithm
        return algorithm
    }
    
    // Delete an algorithm
    func deleteAlgorithm(_ algorithm: Algorithm)  {
        do {
            // If id is 0
            if algorithm.local_id == 0 {
                return
            }
            
            // Get line
            let line = algorithms.filter(local_id == algorithm.local_id)
            
            // Delete data
            try db?.run(line.delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Update owned algorithms
    func updateOwned(owned: [Int64]) {
        do {
            // Get lines
            let lines = algorithms.filter(owned.contains(remote_id))
            
            // Update data
            try db?.run(lines.update(owner <- true))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Check for review
    func checkForReview() {
        // Check number of saves to ask for a review
        let datas = UserDefaults.standard
        let savesCount = datas.integer(forKey: "savesCount") + 1
        datas.set(savesCount, forKey: "savesCount")
        datas.synchronize()
        
        if savesCount == 10 || savesCount == 50 || savesCount % 100 == 0 {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
}

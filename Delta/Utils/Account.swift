//
//  Account.swift
//  Delta
//
//  Created by Nathan FALLET on 26/02/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import Foundation
import APIRequest
import Keychain

class Account: Codable {

    // Singleton instances
    static let keychain = Keychain()
    static let current = Account()

    // Account properties
    var access_token: String?
    var user: APIUser?
    var algorithms: [Int64]?
    
    // Enum for coding keys
    enum CodingKeys: String, CodingKey {
        case access_token, user, algorithms
    }
    
    // Status management
    var loading = false
    
    // Login from keychain
    func login() {
        // Check user data is not already loaded or loading
        guard user == nil && !loading else { return }
        
        // Check token from keychain
        if let access_token = Account.keychain.value(forKey: "access_token") as? String {
            // Login to account
            Account.current.login(access_token: access_token) { status in
                // Check status
                print(status)
            }
        }
    }
    
    // Login with an access token
    func login(access_token: String, completionHandler: @escaping (APIResponseStatus) -> ()) {
        // Save token
        self.access_token = access_token
        self.loading = true
        
        // Fetch api with token
        APIRequest("GET", path: "/auth/account.php").execute(Account.self) { data, status in
            // Check response validity
            if let account = data, status == .ok {
                // Store token and user
                self.access_token = account.access_token
                self.user = account.user
                
                // Update owned algorithms
                if let owned = account.algorithms {
                    Database.current.updateOwned(owned: owned)
                }
            } else if status != .error && status != .offline && status != .originDown {
                // Remove access token (invalid)
                self.access_token = nil
                let _ = Account.keychain.remove(forKey: "access_token")
            }
            
            // Call completion handler
            self.loading = false
            completionHandler(status)
        }
    }
    
    // Login with credentials
    func login(username: String, password: String, completionHandler: @escaping (APIResponseStatus) -> ()) {
        // Fetch api with credentials
        APIRequest("GET", path: "/auth/access_token.php").with(header: "username", value: username).with(header: "password", value: password).execute(Account.self) { data, status in
            // Check response validity
            if let account = data, let access_token = account.access_token, status == .created {
                // Save token to keychain
                let _ = Account.keychain.save(access_token, forKey: "access_token")
                
                // Store token and user
                self.access_token = access_token
                self.user = account.user
                
                // Update owned algorithms
                if let owned = account.algorithms {
                    Database.current.updateOwned(owned: owned)
                }
            }
            
            // Call completion handler
            completionHandler(status)
        }
    }
    
    // Register
    func register(name: String, username: String, password: String, completionHandler: @escaping (APIResponseStatus) -> ()) {
        // Fetch api with data
        APIRequest("POST", path: "/auth/account.php").with(body: [
            "name": name,
            "username": username,
            "password": password
        ]).execute(Account.self) { data, status in
            // Check response validity
            if let account = data, status == .created {
                // Store token and user
                self.access_token = account.access_token
                self.user = account.user
            }
            
            // Call completion handler
            completionHandler(status)
        }
    }
    
    // Logout
    func logout(completionHandler: @escaping (APIResponseStatus) -> ()) {
        // Delete token from API
        APIRequest("DELETE", path: "/auth/access_token.php").execute([String: Bool].self) { data, status in
            // Clear from object
            self.access_token = nil
            self.user = nil
            
            // Clear from keychain
            let _ = Account.keychain.remove(forKey: "access_token")
            
            // Call completion handler
            completionHandler(status)
        }
    }
    
    // Edit profile
    func editProfile(name: String, username: String, password: String, completionHandler: @escaping (APIResponseStatus) -> ()) {
        // Fetch api with data
        APIRequest("PUT", path: "/auth/account.php").with(body: [
            "name": name,
            "username": username,
            "password": password
        ]).execute(Account.self) { data, status in
            // Check response validity
            if let account = data, status == .ok {
                // Update user
                self.user = account.user
            }
            
            // Call completion handler
            completionHandler(status)
        }
    }
    
    // Download data
    func downloadData(completionHandler: @escaping (Exported?, APIResponseStatus) -> ()) {
        // Fetch api with token
        APIRequest("GET", path: "/auth/export.php").execute(Exported.self, completionHandler: completionHandler)
    }
    
    // Delete account
    func delete(completionHandler: @escaping (APIResponseStatus) -> ()) {
        // Delete account from API
        APIRequest("DELETE", path: "/auth/account.php").execute([String: Bool].self) { data, status in
            if status == .ok {
                // Clear from object
                self.access_token = nil
                self.user = nil
                
                // Clear from keychain
                let _ = Account.keychain.remove(forKey: "access_token")
            }
            
            // Call completion handler
            completionHandler(status)
        }
    }

}

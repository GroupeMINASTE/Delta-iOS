//
//  AccountViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 27/06/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    // Views
    let guide = UIView()
    let label = UILabel()
    let button1 = UIButton()
    let button2 = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color
        view.backgroundColor = .background
        
        // Navigation bar
        navigationItem.title = "my_account".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close".localized(), style: .plain, target: self, action: #selector(close(_:)))
        
        // Add views
        view.addSubview(guide)
        view.addSubview(label)
        view.addSubview(button1)
        view.addSubview(button2)
        
        // Configure guide
        guide.translatesAutoresizingMaskIntoConstraints = false
        guide.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        guide.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor).isActive = true
        
        // Configure label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16).isActive = true
        label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        
        // Configure button1
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 64).isActive = true
        button1.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        button1.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button1.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button1.layer.cornerRadius = 10
        button1.layer.masksToBounds = true
        button1.backgroundColor = .systemBlue
        button1.setTitleColor(.white, for: .normal)
        button1.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        
        // Configure button2
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 16).isActive = true
        button2.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16).isActive = true
        button2.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        button2.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button2.layer.cornerRadius = 10
        button2.layer.masksToBounds = true
        button2.backgroundColor = .systemBlue
        button2.setTitleColor(.white, for: .normal)
        button2.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        
        // Load account
        loadAccount()
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        // Dismiss view controller
        dismiss(animated: true, completion: nil)
    }
    
    func loadAccount() {
        // Check for an account
        if let user = Account.current.user {
            // User is logged
            label.text = "logged_as".localized().format(user.name ?? "Unknown", user.username ?? "unknown")
            button1.setTitle("edit_profile".localized(), for: .normal)
            button2.setTitle("sign_out".localized(), for: .normal)
        } else {
            // User is not logged
            label.text = "not_logged".localized()
            button1.setTitle("sign_in".localized(), for: .normal)
            button2.setTitle("sign_up".localized(), for: .normal)
        }
    }
    
    @objc func onClick(_ sender: UIButton) {
        // Check for account
        if Account.current.user != nil {
            // Check button
            if sender == button1 {
                // Edit profile
                
            } else {
                // Sign out
                signOut()
            }
        } else {
            // Check button
            if sender == button1 {
                // Sign in
                signIn()
            } else {
                // Sign up
                signUp()
            }
        }
    }
    
    func signIn() {
        // Create an alert
        let alert = UIAlertController(title: "sign_in".localized(), message: "sign_in_description".localized(), preferredStyle: .alert)
        
        // Add username field
        alert.addTextField { field in
            // Configure it
            field.placeholder = "field_username".localized()
        }
        
        // Add password field
        alert.addTextField { field in
            // Configure it
            field.placeholder = "field_password".localized()
            field.isSecureTextEntry = true
        }
        
        // Add login button
        alert.addAction(UIAlertAction(title: "sign_in".localized(), style: .default) { _ in
            // Extract text from fields
            if let username = alert.textFields?[0].text, let password = alert.textFields?[1].text, !username.isEmpty, !password.isEmpty {
                // Show a loading
                let loading = UIAlertController(title: "loading".localized(), message: nil, preferredStyle: .alert)
                self.present(loading, animated: true, completion: nil)
                
                // Start login process
                Account.current.login(username: username, password: password) { status in
                    // Refresh the UI
                    self.loadAccount()
                    loading.dismiss(animated: true) {
                        // Check for a 404
                        if status == .notFound {
                            // User not found, show an alert
                            let error = UIAlertController(title: "sign_in".localized(), message: "sign_in_error".localized(), preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
                            self.present(error, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        
        // Add cancel button
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        
        // Show it
        present(alert, animated: true, completion: nil)
    }
    
    func signUp() {
        // Create an alert
        let alert = UIAlertController(title: "sign_up".localized(), message: "sign_up_description".localized(), preferredStyle: .alert)
        
        // Add name field
        alert.addTextField { field in
            // Configure it
            field.placeholder = "field_name".localized()
        }
        
        // Add username field
        alert.addTextField { field in
            // Configure it
            field.placeholder = "field_username".localized()
        }
        
        // Add password field
        alert.addTextField { field in
            // Configure it
            field.placeholder = "field_password".localized()
            field.isSecureTextEntry = true
        }
        
        // Add login button
        alert.addAction(UIAlertAction(title: "sign_up".localized(), style: .default) { _ in
            // Extract text from fields
            if let name = alert.textFields?[0].text, let username = alert.textFields?[1].text, let password = alert.textFields?[2].text, !name.isEmpty, !username.isEmpty, !password.isEmpty {
                // Show a loading
                let loading = UIAlertController(title: "loading".localized(), message: nil, preferredStyle: .alert)
                self.present(loading, animated: true, completion: nil)
                
                // Start register process
                Account.current.register(name: name, username: username, password: password) { status in
                    // Refresh the UI
                    self.loadAccount()
                    loading.dismiss(animated: true) {
                        // Check for a 400
                        if status == .badRequest {
                            // Username already taken
                            let error = UIAlertController(title: "sign_up".localized(), message: "sign_up_error".localized(), preferredStyle: .alert)
                            error.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
                            self.present(error, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        
        // Add cancel button
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        
        // Show it
        present(alert, animated: true, completion: nil)
    }
    
    func signOut() {
        // Show a loading
        let loading = UIAlertController(title: "loading".localized(), message: nil, preferredStyle: .alert)
        self.present(loading, animated: true, completion: nil)
        
        // Just call API
        Account.current.logout { _ in
            // Reload the view
            self.loadAccount()
            loading.dismiss(animated: true, completion: nil)
        }
    }

}

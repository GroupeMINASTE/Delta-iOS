//
//  QuizViewController.swift
//  Delta
//
//  Created by Nathan FALLET on 18/03/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import DigiAnalytics

class QuizViewController: UIViewController, UITextFieldDelegate {

    let quiz: Quiz
    let completionHandler: () -> ()
    var checked = false
    let scrollView = UIScrollView()
    let contentView = UIView()
    let header = UILabel()
    let stack = UIStackView()
    let button = UIButton()
    var bottomConstraint: NSLayoutConstraint!
    
    init(_ quiz: Quiz, completionHandler: @escaping () -> ()) {
        self.quiz = quiz
        self.completionHandler = completionHandler
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "category_quiz".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel".localized(), style: .plain, target: self, action: #selector(close(_:)))
        
        view.backgroundColor = .background
        
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        
        scrollView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        contentView.addSubview(header)
        contentView.addSubview(stack)
        contentView.addSubview(button)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        header.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 15).isActive = true
        header.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -15).isActive = true
        header.font = .boldSystemFont(ofSize: 17)
        header.textAlignment = .center
        header.attributedText = quiz.text.attributedMath()
        header.numberOfLines = 0
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16).isActive = true
        stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stack.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stack.axis = .vertical
        stack.spacing = 4
        
        for i in 0 ..< quiz.elements.count {
            if let question = quiz.elements[i] as? QuizQuestion {
                let questionStack = UIStackView()
                let questionLabel = UILabel()
                let questionField = UITextField()
                
                questionStack.axis = .horizontal
                questionStack.spacing = 6

                questionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                questionLabel.setContentHuggingPriority(.required, for: .horizontal)
                questionLabel.adjustsFontSizeToFitWidth = true
                questionLabel.attributedText = "\(question.text) =".attributedMath()
                
                questionField.setContentCompressionResistancePriority(.required, for: .horizontal)
                questionField.autocapitalizationType = .none
                questionField.returnKeyType = .done
                questionField.delegate = self
                questionField.tag = i
                
                questionStack.addArrangedSubview(questionLabel)
                questionStack.addArrangedSubview(questionField)
                
                stack.addArrangedSubview(questionStack)
            } else if let paragraph = quiz.elements[i] as? QuizParagraph {
                let paragraphLabel = UILabel()

                paragraphLabel.adjustsFontSizeToFitWidth = true
                paragraphLabel.attributedText = paragraph.text.attributedMath()
                
                stack.addArrangedSubview(paragraphLabel)
            }
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 16).isActive = true
        button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        button.setTitle("check".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Send analytics
        DigiAnalytics.shared.send(path: "quiz")
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            // Call completion handler
            self.completionHandler()
        }
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        if checked {
            // Dismiss view
            dismiss(animated: true) {
                // Call completion handler
                self.completionHandler()
            }
        } else {
            // Get fields
            for subview in stack.arrangedSubviews {
                // Extract field if exists
                if let subview = subview as? UIStackView, let label = subview.arrangedSubviews[0] as? UILabel, let field = subview.arrangedSubviews[1] as? UITextField, let question = quiz.elements[field.tag] as? QuizQuestion {
                    // Check the question
                    let answer = TokenParser(field.text).execute()
                    let condition = Equation(left: answer, right: question.correct, operation: .equals)
                    
                    if condition.isTrue(with: [:]) {
                        // Answer is correct
                        label.textColor = .systemGreen
                        field.textColor = .systemGreen
                    } else {
                        // Answer is not correct
                        label.textColor = .systemRed
                        field.textColor = .systemRed
                    }
                    
                    // Disable the field
                    field.isEnabled = false
                }
            }
            
            // Set as checked
            checked = true
            button.setTitle("close".localized(), for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    @objc func keyboardChanged(_ sender: NSNotification) {
        if let userInfo = sender.userInfo {
            // Adjust frame to keyboard
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let isKeyboardShowing = sender.name == UIResponder.keyboardWillShowNotification
            bottomConstraint.constant = isKeyboardShowing ? -((keyboardFrame?.height ?? 0)) : 0
            
            // And animate the transition
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

}

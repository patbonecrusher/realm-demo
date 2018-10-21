//
//  ProjectViewController.swift
//  realm-demo
//
//  Created by Patrick Laplante on 10/21/18.
//  Copyright © 2018 Patrick Laplante. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectViewController: UIViewController, UITextViewDelegate {
    var project: Project?
    var notificationToken: NotificationToken?

    var projectNameTextField: UITextField?
    var inspectorNameTextField: UITextField?
    var clientNameTextField: UITextField?
    var commentsTextField: UITextView?

    override func viewDidLoad() {
        title = project?.name ?? "Unnamed Project"
        view.backgroundColor = .white
        
        //Project name
        let projectNameLabel = UILabel()
        projectNameLabel.backgroundColor = UIColor.lightGray
        projectNameLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        projectNameLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        projectNameLabel.text  = "Project name: ";
        projectNameLabel.textAlignment = .left
        
        projectNameTextField = UITextField()
        projectNameTextField?.backgroundColor = UIColor.lightGray
        projectNameTextField?.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        projectNameTextField?.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        projectNameTextField?.text  = project?.name
        projectNameTextField?.textAlignment = .left
        
        //inspector name
        let inspectorNameLabel = UILabel()
        inspectorNameLabel.backgroundColor = UIColor.lightGray
        inspectorNameLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        inspectorNameLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        inspectorNameLabel.text  = "Inspector name: ";
        inspectorNameLabel.textAlignment = .left

        inspectorNameTextField = UITextField()
        inspectorNameTextField?.backgroundColor = UIColor.lightGray
        inspectorNameTextField?.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        inspectorNameTextField?.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        inspectorNameTextField?.text  = project?.inspectorName
        inspectorNameTextField?.textAlignment = .left

        //client name
        let clientNameLabel = UILabel()
        clientNameLabel.backgroundColor = UIColor.lightGray
        clientNameLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        clientNameLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        clientNameLabel.text  = "Client Name"
        clientNameLabel.textAlignment = .left
        
        clientNameTextField = UITextField()
        clientNameTextField?.backgroundColor = UIColor.lightGray
        clientNameTextField?.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        clientNameTextField?.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        clientNameTextField?.text  = project?.clientName
        clientNameTextField?.textAlignment = .left

        //comments
        let commentsNameLabel = UILabel()
        commentsNameLabel.backgroundColor = UIColor.lightGray
        commentsNameLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        commentsNameLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        commentsNameLabel.text  = "Comments"
        commentsNameLabel.textAlignment = .left
        
        commentsTextField = UITextView()
        commentsTextField?.backgroundColor = UIColor.lightGray
        commentsTextField?.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        commentsTextField?.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        commentsTextField?.text  = project?.comments
        commentsTextField?.textAlignment = .left
        commentsTextField?.textColor = UIColor.black
        commentsTextField?.delegate = self
        

        //Stack View
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.top
        stackView.spacing   = 16.0
        
        stackView.addArrangedSubview(projectNameLabel)
        stackView.addArrangedSubview(projectNameTextField!)
        stackView.addArrangedSubview(inspectorNameLabel)
        stackView.addArrangedSubview(inspectorNameTextField!)
        stackView.addArrangedSubview(clientNameLabel)
        stackView.addArrangedSubview(clientNameTextField!)
        stackView.addArrangedSubview(commentsNameLabel)
        stackView.addArrangedSubview(commentsTextField!)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        //Constraints
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonDidClick))
    
        // THIS REQUIRES SOME THINKING.  DO YOU REFRESH THE UI IF SOMEONE CHANGES IT? OR DO YOU WARN THE USER?
        notificationToken = project?.observe { [weak self] (changes) in
            switch changes {
            case .change(let propertyChanges):
                for propChange in propertyChanges {
                    print("'\(propChange.name)': \(String(describing: propChange.oldValue)) -> \(String(describing: propChange.newValue))")
                }
            case .deleted:
                print("del")
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == UIColor.lightGray {
//            textView.text = nil
//            textView.textColor = UIColor.black
//        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Placeholder"
//            textView.textColor = UIColor.lightGray
//        }
    }
    
    
    
    deinit {
        notificationToken?.invalidate()
    }

    @objc func saveButtonDidClick() {
        //project.owner = SyncUser.current!.identity!
        try! self.project?.realm?.write {
            project?.name = projectNameTextField?.text ?? ""
            project?.inspectorName = inspectorNameTextField?.text ?? ""
            project?.clientName = clientNameTextField?.text ?? ""
            project?.comments = commentsTextField?.text ?? ""
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}


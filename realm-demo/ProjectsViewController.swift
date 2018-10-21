//
//  ProjectsViewController.swift
//  realm-demo
//
//  Created by Patrick Laplante on 10/21/18.
//  Copyright © 2018 Patrick Laplante. All rights reserved.
//

import Foundation
import RealmSwift

class ProjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm: Realm
    let projects: Results<Project>
    var notificationToken: NotificationToken?
    var subscriptionToken: NotificationToken?
    var subscription: SyncSubscription<Project>!
    
    var tableView = UITableView()
    let activityIndicator = UIActivityIndicatorView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let syncConfig2 = SyncConfiguration(user: SyncUser.current!, realmURL: Constants.REALM_URL, enableSSLValidation: true, isPartial: true)
        
        self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig2))
        
        projects = realm.objects(Project.self).filter("owner = %@", SyncUser.current!.identity!).sorted(byKeyPath: "timestamp", ascending: false)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Projects"
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.color = .darkGray
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true
        
        tableView.frame = self.view.frame
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemButtonDidClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonDidClick))
        
        // In a Partial Sync use case this is where we tell the server we want to
        // subscribe to a particular query.
        subscription = projects.subscribe(named: "my-projects")
        
        activityIndicator.startAnimating()
        subscriptionToken = subscription.observe(\.state, options: .initial) { state in
            if state == .complete {
                self.activityIndicator.stopAnimating()
            } else {
                print("Subscription State: \(state)")
            }
        }
        
        
        notificationToken = projects.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
        subscriptionToken?.invalidate()
        activityIndicator.stopAnimating()
    }
    
    @objc func addItemButtonDidClick() {
        let alertController = UIAlertController(title: "Add New Project", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            let project = Project()
            project.name = textField.text ?? ""
            project.owner = SyncUser.current!.identity!
            try! self.realm.write {
                self.realm.add(project)
            }
            // do something with textField
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "New Item Text"
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func logoutButtonDidClick() {
        let alertController = UIAlertController(title: "Logout", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes, Logout", style: .destructive, handler: {
            alert -> Void in
            SyncUser.current?.logOut()
            self.navigationController?.setViewControllers([WelcomeViewController()], animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        let project = projects[indexPath.row]
        cell.textLabel?.text = project.name
        cell.detailTextLabel?.text = project.clientName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = projects[indexPath.row]
        let projectVC = ProjectViewController()
        projectVC.project = project
        self.navigationController?.pushViewController(projectVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let project = projects[indexPath.row]
        deleteProject(project)
    }
    
    @objc func confirmDeleteProjectAndTasks(project: Project) {
        let alertController = UIAlertController(title: "Delete \(project.name)?", message: "This will deleteit!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes, Delete \(project.name)", style: .destructive, handler: {
            alert -> Void in
            self.deleteProject(project)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteProject(_ project:Project) {
        try! realm.write {
            realm.delete(project)
        }
    }
    
}

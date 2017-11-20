//
//  AppsViewController.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Piotr Sochalewski. All rights reserved.
//

import UIKit
import GRDB

final class AppsViewController: UITableViewController {

    private var appsController: FetchedRecordsController<App>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appsController = try! FetchedRecordsController(dbQueue, request: App.order(Column("name")))
        
        appsController
            .trackChanges(willChange: { [unowned self] _ in
                self.tableView.beginUpdates()
            },
            onChange: { [unowned self] (controller, record, change) in
                switch change {
                case .insertion(let indexPath):
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                case .deletion(let indexPath):
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                default:
                    break
                }
            },
            didChange: { [unowned self] _ in
                self.tableView.endUpdates()
            })
        
        try! appsController.performFetch()
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "New app", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .sentences
            textField.addTarget(self, action: #selector(AppsViewController.appNameChanged(_:)), for: .editingChanged)
        }
        
        let createAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let appName = alert.textFields?.first?.text else { return }
            
            DispatchQueue.global().async {
                try! dbQueue.inTransaction { db in
                    let app = App(name: appName)
                    try app.insert(db)
                    
                    return .commit
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [createAction, cancelAction].forEach { alert.addAction($0) }
        alert.actions.first?.isEnabled = false
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func appNameChanged(_ sender: UITextField) {
        var responder = sender as UIResponder
        while !(responder is UIAlertController) {
            responder = responder.next!
        }
        let alert = responder as! UIAlertController
        alert.actions.first?.isEnabled = (sender.text != "")
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return appsController.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appsController.sections[section].numberOfRecords
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let app = appsController.record(at: indexPath)
        cell.textLabel?.text = app.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let app = appsController.record(at: indexPath)
        try! dbQueue.inDatabase { db in
            _ = try app.delete(db)
        }
    }
}

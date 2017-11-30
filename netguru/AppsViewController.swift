//
//  AppsViewController.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Piotr Sochalewski. All rights reserved.
//

import UIKit
import GRDB

final class AppsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private lazy var dataSource = GRDBTableViewDelegate<App>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let appDetailsViewController = segue.destination as? AppDetailsViewController,
            let indexPath = tableView.indexPathForSelectedRow,
            segue.identifier == "detail" else { return }
        
        let app = dataSource.controller.record(at: indexPath)
        appDetailsViewController.app = app
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func setupTableView() {
        try! dataSource.controller.performFetch()
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.tableFooterView = UIView()

        dataSource.controller
            .trackChanges(willChange: { [unowned self] _ in
                self.tableView.beginUpdates()
            }, onChange: { [unowned self] _, _, change in
                switch change {
                case .insertion(let indexPath):
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                case .deletion(let indexPath):
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                default:
                    break
                }
            }, didChange: { [unowned self] _ in
                self.tableView.endUpdates()
            })
    }
    
    @IBAction private func addButtonAction(_ sender: Any) {
        presentAddAlert(title: "New app", placeholder: "Name") { appName in
            DispatchQueue.global().async {
                try! dbQueue.inTransaction { db in
                    let app = App(name: appName)
                    try app.insert(db)
                    
                    return .commit
                }
            }
        }
    }
}

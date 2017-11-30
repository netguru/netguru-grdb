//
//  DevsViewController.swift
//  netguru
//
//  Created by Piotr Sochalewski on 27.11.2017.
//  Copyright © 2017 Piotr Sochalewski. All rights reserved.
//

import UIKit
import GRDB

final class DevsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private var dataSource: GRDBTableViewDelegate<Developer>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = GRDBTableViewDelegate<Developer>()
        setupTableView()
    }
    
    private func setupTableView() {
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
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
        
        try! dataSource.controller.performFetch()
    }
    
    @IBAction private func addButtonAction(_ sender: Any) {
        presentAddAlert(title: "New developer", placeholder: "Name") { appName in
            DispatchQueue.global().async {
                try! dbQueue.inTransaction { db in
                    let app = Developer(name: appName)
                    try app.insert(db)
                    
                    return .commit
                }
            }
        }
    }
}

//
//  AppDetailsViewController.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import GRDB

final class SelectableGRDBTableViewDelegate<T: Record & TextRepresentable>: GRDBTableViewDelegate<T> {
    
    private let app: App
    
    init(app: App) {
        self.app = app
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath),
            let developer = controller.record(at: indexPath) as? Developer else { return }
        try! dbQueue.inTransaction { db in
            developer.appId = cell.accessoryType == .none ? app.id : nil
            try developer.update(db)
            
            return .commit
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let developer = controller.record(at: indexPath) as! Developer
        cell.textLabel?.text = developer.name
        cell.accessoryType = developer.appId == app.id ? .checkmark : .none
        return cell
    }
}

final class AppDetailsViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var app: App!
    private lazy var dataSource = SelectableGRDBTableViewDelegate<Developer>(app: app!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = app.name
        setupTableView()
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
                case .update(let indexPath, _):
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                default:
                    break
                }
            }, didChange: { [unowned self] _ in
                self.tableView.endUpdates()
        })
    }
}

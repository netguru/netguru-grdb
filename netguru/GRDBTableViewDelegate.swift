//
//  GRDBTableViewDelegate.swift
//  netguru
//
//  Created by Piotr Sochalewski on 27.11.2017.
//  Copyright © 2017 Piotr Sochalewski. All rights reserved.
//

import GRDB
import UIKit

class GRDBTableViewDelegate<T: Record & TextRepresentable>: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let controller = try! FetchedRecordsController(dbQueue, request: T.order(Column("name")))

    func numberOfSections(in tableView: UITableView) -> Int {
        return controller.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.sections[section].numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = controller.record(at: indexPath)
        cell.textLabel?.text = object.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let object = controller.record(at: indexPath)
        try! dbQueue.inDatabase { db in
            _ = try object.delete(db)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

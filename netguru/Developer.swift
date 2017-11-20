//
//  Developer.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Piotr Sochalewski. All rights reserved.
//

import GRDB

final class Developer: Record {
    
    var id: Int64?
    var name: String
    
    init(name: String, score: Int) {
        self.name = name
        super.init()
    }
    
    // MARK: Record overrides
    
    override class var databaseTableName: String {
        return "developers"
    }
    
    required init(row: Row) {
        id = row["id"]
        name = row["name"]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["name"] = name
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

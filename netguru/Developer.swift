//
//  Developer.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Piotr Sochalewski. All rights reserved.
//

import GRDB

final class Developer: Record, TextRepresentable {
    
    var id: Int64?
    var name: String
    var appId: Int64?
    
    init(name: String) {
        self.name = name
        self.appId = nil
        super.init()
    }
    
    override class var databaseTableName: String {
        return "developers"
    }
    
    required init(row: Row) {
        id = row["id"]
        name = row["name"]
        appId = row["appId"]
        
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["name"] = name
        container["appId"] = appId
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

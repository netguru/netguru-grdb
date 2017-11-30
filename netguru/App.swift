//
//  Developer.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Piotr Sochalewski. All rights reserved.
//

import GRDB

final class App: Record, TextRepresentable {

    var id: Int64?
    var name: String
    var developer: QueryInterfaceRequest<Developer> {
        return Developer.filter(Column("appId") == id)
    }
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    // MARK: Record overrides
    
    override class var databaseTableName: String {
        return "apps"
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

//
//  Developer.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import GRDB

final class Developer: Record, TextRepresentable {
    
    var id: Int64?
    var name: String
    var appId: Int64?
    var app: QueryInterfaceRequest<App> {
        return App.filter(Column("id") == appId)
    }
    
    override class var databaseTableName: String {
        return "developers"
    }
    
    init(name: String) {
        self.name = name
        self.appId = nil
        super.init()
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

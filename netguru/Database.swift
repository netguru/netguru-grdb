//
//  Database.swift
//  netguru
//
//  Created by Piotr Sochalewski on 20.11.2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import GRDB

/// A type responsible for initializing the application database.
struct Database {
    
    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        // Connect to the database
        dbQueue = try DatabaseQueue(path: path)
        
        // Use DatabaseMigrator to define the database schema
        try migrator.migrate(dbQueue)
        
        return dbQueue
    }
    
    /// The DatabaseMigrator that defines the database schema.
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createDevelopers") { db in
            // Create a table
            try db.create(table: Developer.databaseTableName) { t in
                // An integer primary key auto-generates unique IDs
                t.column("id", .integer).primaryKey()
                
                // An integer key that referencens App's id colument
                t.column("appId", .integer).references(App.databaseTableName, column: "id")

                // Sort person names in a localized case insensitive fashion by default
                t.column("name", .text).notNull().collate(.localizedCaseInsensitiveCompare)
            }
        }
        
        migrator.registerMigration("createApps") { db in
            // Create a table
            try db.create(table: App.databaseTableName) { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull().collate(.localizedCaseInsensitiveCompare)
            }
        }
        
//        migrator.registerMigration("fixtures") { db in
//            // Populate the developers table with random data
//            (1..<8).forEach {
//                try Developer(name: "Developer \($0)").insert(db)
//            }
//        }
        
        return migrator
    }
}

//
//  CreateCategory.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Fluent

struct CreateCategory : Migration {
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories").delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
}

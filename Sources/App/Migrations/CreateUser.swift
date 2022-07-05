//
//  CreateUser.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Fluent

struct CreateUser : Migration {
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .create()
    }
}

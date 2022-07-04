//
//  CreateAcronym.swift
//  
//
//  Created by polykuzin on 04/07/2022.
//

import Fluent

struct CreateAcronym : Migration {
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms")
            .id()
            .field("long", .string, .required)
            .field("short", .string, .required)
            .create()
    }
}

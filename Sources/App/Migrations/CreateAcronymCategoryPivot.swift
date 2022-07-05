//
//  CreateAcronymCategoryPivot.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Fluent

struct CreateAcronymCategoryPivot : Migration {
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronym-category-pivot").delete()
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronym-category-pivot")
            .id()
            .field("acronymID", .uuid, .references("acronyms", "id", onDelete: .cascade))
            .field("categoryID", .uuid, .references("categories", "id", onDelete: .cascade))
            .create()
    }
}

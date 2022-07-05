//
//  Category.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Vapor
import Fluent

final class Category : Model {
    
    static let schema : String = "categories"
    
    @ID
    public var id : UUID?
    
    @Field(key: "name")
    public var name : String
    
    @Siblings(
        through: AcronymCategoryPivot.self,
        from: \.$category,
        to: \.$acronym
    )
    public var acronyms : [Acronym]
    
    public init() { }
    
    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Category : Content { }

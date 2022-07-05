//
//  AcronymCategoryPivot.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Fluent
import Foundation

final class AcronymCategoryPivot : Model {
    
    static let schema = "acronym-category-pivot"
    
    @ID
    public var id : UUID?
    
    @Parent(key: "acronymID")
    public var acronym : Acronym
    
    @Parent(key: "categoryID")
    public var category : Category
    
    public init() { }
    
    public init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}

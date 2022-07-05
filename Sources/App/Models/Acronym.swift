//
//  Acronym.swift
//  
//
//  Created by polykuzin on 04/07/2022.
//

import Vapor
import Fluent

final class Acronym : Model {
        
    public init() { }
    
    @ID
    public var id : UUID?
    
    @Field(key: "long")
    public var long : String
    
    @Parent(key: "userID")
    public var userID : User
    
    @Field(key: "short")
    public var short : String
    
    @Siblings(
        through: AcronymCategoryPivot.self,
        from: \.$acronym,
        to: \.$category
    )
    public var categories : [Category]
    
    static public let schema : String = "acronyms"
    
    public init(id: UUID? = nil, userID: User.IDValue, long: String, short: String) {
        self.id = id
        self.long = long
        self.short = short
        self.$userID.id = userID
    }
}

extension Acronym : Content { }

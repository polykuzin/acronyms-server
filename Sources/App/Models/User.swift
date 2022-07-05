//
//  User.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Vapor
import Fluent

final class User : Model {
    
    static let schema : String = "users"
    
    @ID
    var id : UUID?
    
    @Field(key: "name")
    var name : String
    
    @Field(key: "username")
    var username : String
    
    @Children(for: \.$userID)
    var acronyms : [Acronym]
    
    public init() { }
    
    public init(id: UUID? = nil, name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User : Content { }

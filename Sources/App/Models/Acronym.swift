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
    
    @Field(key: "short")
    public var short : String
    
    static public let schema : String = "acronyms"
    
    public init(id: UUID? = nil, long: String, short: String) {
        self.id = id
        self.long = long
        self.short = short
    }
}

extension Acronym : Content { }

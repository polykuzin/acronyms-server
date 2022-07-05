//
//  UserController.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Vapor

struct UserController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.get(use: getAllHandler(_:))
        usersRoute.post(use: createHandler(_:))
        usersRoute.get(":id", use: getAllHandler(_:))
        usersRoute.get("acronyms", ":userID", use: getAcronymsHandler)
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<User> {
        User.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
}

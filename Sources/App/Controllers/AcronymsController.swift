//
//  AcronymsController.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Vapor
import Fluent

struct CreateAcronymData : Content {
    let long : String
    let short : String
    let userID : UUID
}

struct AcronymsController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(":id", use: getHandler)
        acronymsRoutes.put(":id", use: updateHandler)
        acronymsRoutes.delete(":id", use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.delete("deleteAll", use: deleteAllHandler)
        acronymsRoutes.get("user", ":acronymID", use: getUserHandler)
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$userID.get(on: req.db)
            }
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db)
            .all()
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        return Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func sortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
    
    func deleteAllHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Acronym.query(on: req.db)
            .all()
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(
            userID: data.userID,
            long: data.long,
            short: data.short
        )
        return acronym.save(on: req.db).map { acronym }
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updateData = try req.content.decode(CreateAcronymData.self)
        return Acronym
            .find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.long = updateData.long
                acronym.short = updateData.short
                acronym.$userID.id = updateData.userID
                return acronym.save(on: req.db).map {
                    acronym
                }
            }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard
            let searchItem = req.query[String.self, at: "term"]
        else { throw Abort(.badRequest) }
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$long == searchItem)
            or.filter(\.$short == searchItem)
        }.all()
    }
}

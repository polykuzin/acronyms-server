//
//  AcronymsController.swift
//  
//
//  Created by polykuzin on 05/07/2022.
//

import Vapor
import Fluent

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
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
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
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db).map { acronym }
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updated = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.long = updated.long
                acronym.short = updated.short
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
}

import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    /// add new Acronym
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db).map {
            acronym
        }
    }
    
    /// retrieve all acronyms
    app.get("api", "acronyms") { req -> EventLoopFuture<[Acronym]> in
        Acronym.query(on: req.db).all()
    }
    
    /// get acronym by id
    app.get("api", "acronyms", ":id") { req -> EventLoopFuture<Acronym> in
        Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    /// update acronym value with put method
    app.put("api", "acronyms", ":id") { req -> EventLoopFuture<Acronym> in
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
    
    /// get first result of a query
    app.get("api", "acronyms", "first") { req -> EventLoopFuture<Acronym> in
        Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    /// get sorted result of all acronyms
    app.get("api", "acronyms", "sorted") { req -> EventLoopFuture<[Acronym]> in
        Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
    
    /// searching in a database /search?term=OMG
    app.get("api", "acronyms", "search") { req -> EventLoopFuture<[Acronym]> in
        guard let searchItem = req.query[String.self, at: "term"] else { throw Abort(.badRequest) }
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$long == searchItem)
            or.filter(\.$short == searchItem)
        }.all()
    }
    
    /// deleting single acronym by id
    app.delete("api", "acronyms", ":id") { req -> EventLoopFuture<HTTPStatus> in
        Acronym.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}

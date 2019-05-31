import FluentSQLite
import Vapor

final class TokenController: RouteCollection {
    
    func boot(router: Router) throws {
        let routes = router.grouped("api", "token")
        routes.post(Token.self, use: storeToken)
        routes.delete(String.parameter, String.parameter, use: removeToken)
        routes.get(use: getToken)
        routes.get(String.parameter, use: getTokenWithBundle)
    }
    
    func storeToken(_ req: Request, token: Token) throws -> Future<Token> {
        return token.save(on: req)
    }
    
    func removeToken(_ req: Request) throws -> Future<HTTPStatus> {
        let appIdentifier = try req.parameters.next(String.self)
        let tokenStr = try req.parameters.next(String.self)
        
        return Token.query(on: req)
            .filter(\.appIdentifier == appIdentifier)
            .filter(\.token == tokenStr)
            .delete()
            .transform(to: .ok)
    }
    
    func getToken(_ req: Request) throws -> Future<[Token]> {
        return Token.query(on: req).all()
    }
    
    func getTokenWithBundle(_ req: Request) throws -> Future<[Token]> {
        let appIdentifier = try req.parameters.next(String.self)
        return Token.query(on: req)
            .filter(\.appIdentifier == appIdentifier)
            .all()
    }
    
}

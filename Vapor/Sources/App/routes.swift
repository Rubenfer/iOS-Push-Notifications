import Routing
import Vapor

public func routes(_ router: Router) throws {
    let tokenController = TokenController()
    try router.register(collection: tokenController)
}

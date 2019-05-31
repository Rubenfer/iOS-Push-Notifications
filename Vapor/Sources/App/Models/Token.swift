import FluentSQLite
import Vapor

final class Token: SQLiteUUIDModel {
    static let entity = "tokens"

    var id: UUID?
    let token: String
    let appIdentifier: String
    let debug: Bool

    init(token: String, appIdentifier: String, debug: Bool) {
        self.token = token
        self.appIdentifier = appIdentifier
        self.debug = debug
    }
}

extension Token: Migration {
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.token)
        }
    }
}

extension Token: Content {}
extension Token: Parameter {}

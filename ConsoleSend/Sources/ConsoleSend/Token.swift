import Foundation

struct Token: Decodable {
    
    var id: UUID?
    let token: String
    let appIdentifier: String
    let debug: Bool
    
    func remove(from apiUrl: String) {
        guard var url = URL(string: apiUrl) else { return }
        url.appendPathComponent(appIdentifier + "/" + token)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request).resume()
    }
    
    static func getTokens(from url: String) -> [Token] {
        let dispatchGroup = DispatchGroup()
        var tokens: [Token] = []
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: URL(string: url)!) { data, _, _ in
            guard let data = data else { fatalError("No data") }
            do {
                tokens = try JSONDecoder().decode([Token].self, from: data)
                dispatchGroup.leave()
            } catch {
                print(error)
            }
            }.resume()
        dispatchGroup.wait()
        return tokens
    }
    
}

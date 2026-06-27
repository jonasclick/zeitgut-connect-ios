import Foundation

struct APIEndpoint<Response: Decodable> {
    let path: String
    let method: HTTPMethod
    let body: Data?
    let accessToken: String?

    init(
        path: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        accessToken: String? = nil
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.accessToken = accessToken
    }
}

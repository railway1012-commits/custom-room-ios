import Foundation

public class APIClient {
    public static let shared = APIClient()
    public var baseURL = "https://rooms.synchapp.dev"

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpCookieAcceptPolicy = .always
        self.session = URLSession(configuration: config)
    }

    // MARK: - Rooms
    public func fetchRooms() async throws -> [Room] {
        guard let url = URL(string: "\(baseURL)/api/rooms") else { return [] }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Room].self, from: data)
    }

    public func fetchSignups() async throws -> [Signup] {
        guard let url = URL(string: "\(baseURL)/api/signups") else { return [] }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Signup].self, from: data)
    }

    // MARK: - Auth
    public func login(email: String, pass: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/api/auth/login") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": email, "password": pass]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errMsg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? String
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: errMsg ?? "Authentication failed"])
        }
        return try JSONDecoder().decode(User.self, from: data)
    }

    public func signup(email: String, pass: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/api/auth/register") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": email, "password": pass]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errMsg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? String
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: errMsg ?? "Registration failed"])
        }
        return try JSONDecoder().decode(User.self, from: data)
    }

    public func logout() async throws {
        guard let url = URL(string: "\(baseURL)/api/auth/logout") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        _ = try? await session.data(for: request)
    }

    public func createSignup(roomId: String, ign: String, uid: String, discord: String?, squad: String?) async throws -> Signup {
        guard let url = URL(string: "\(baseURL)/api/signups") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = [
            "room_id": roomId,
            "ign": ign,
            "uid": uid
        ]
        if let discord = discord, !discord.isEmpty { body["discord"] = discord }
        if let squad = squad, !squad.isEmpty { body["squad"] = squad }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Signup.self, from: data)
    }
}

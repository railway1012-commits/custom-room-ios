import Foundation

public struct User: Identifiable, Codable, Equatable {
    public let id: String
    public let email: String
    public let role: String

    public var isOwner: Bool {
        role.lowercased() == "admin" || role.lowercased() == "owner"
    }

    public init(id: String, email: String, role: String = "user") {
        self.id = id
        self.email = email
        self.role = role
    }
}

public struct GamerProfile: Codable, Equatable {
    public var defaultIgn: String
    public var defaultUid: String
    public var defaultDiscord: String
    public var defaultSquad: String

    public init(
        defaultIgn: String = "",
        defaultUid: String = "",
        defaultDiscord: String = "",
        defaultSquad: String = ""
    ) {
        self.defaultIgn = defaultIgn
        self.defaultUid = defaultUid
        self.defaultDiscord = defaultDiscord
        self.defaultSquad = defaultSquad
    }
}

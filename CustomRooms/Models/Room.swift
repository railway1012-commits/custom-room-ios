import Foundation

public struct Room: Identifiable, Codable, Equatable {
    public let id: String
    public var title: String
    public var photo: String?
    public var dateTime: String
    public var mode: String
    public var ucPerKill: Double
    public var maxPlayers: Int
    public var status: String
    public var revealDetails: Bool
    public var roomId: String?
    public var roomPassword: String?
    public var notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case photo
        case dateTime = "date_time"
        case mode
        case ucPerKill = "uc_per_kill"
        case maxPlayers = "max_players"
        case status
        case revealDetails = "reveal_details"
        case roomId = "room_id"
        case roomPassword = "room_password"
        case notes
    }

    public init(
        id: String = UUID().uuidString,
        title: String = "",
        photo: String? = nil,
        dateTime: String = "",
        mode: String = "Squad",
        ucPerKill: Double = 10.0,
        maxPlayers: Int = 100,
        status: String = "Open",
        revealDetails: Bool = false,
        roomId: String? = nil,
        roomPassword: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.photo = photo
        self.dateTime = dateTime
        self.mode = mode
        self.ucPerKill = ucPerKill
        self.maxPlayers = maxPlayers
        self.status = status
        self.revealDetails = revealDetails
        self.roomId = roomId
        self.roomPassword = roomPassword
        self.notes = notes
    }
}

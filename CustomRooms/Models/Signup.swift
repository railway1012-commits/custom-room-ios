import Foundation

public struct Signup: Identifiable, Codable, Equatable {
    public let id: String
    public let roomId: String
    public let createdById: String
    public var ign: String
    public var uid: String
    public var discord: String?
    public var squad: String?
    public var rank: String
    public var kills: Int
    public var ucAmount: Double
    public var payoutStatus: String

    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case createdById = "created_by_id"
        case ign
        case uid
        case discord
        case squad
        case rank
        case kills
        case ucAmount = "uc_amount"
        case payoutStatus = "payout_status"
    }

    public init(
        id: String = UUID().uuidString,
        roomId: String,
        createdById: String,
        ign: String,
        uid: String,
        discord: String? = nil,
        squad: String? = nil,
        rank: String = "none",
        kills: Int = 0,
        ucAmount: Double = 0.0,
        payoutStatus: String = "Pending"
    ) {
        self.id = id
        self.roomId = roomId
        self.createdById = createdById
        self.ign = ign
        self.uid = uid
        self.discord = discord
        self.squad = squad
        self.rank = rank
        self.kills = kills
        self.ucAmount = ucAmount
        self.payoutStatus = payoutStatus
    }
}

public struct NotificationDTO: Decodable {
    public let id: String
    public let title: String
    public let message: String
    public let date: String
    public let isRead: Bool
    public let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, date, type
        case isRead = "is_read"
    }
}

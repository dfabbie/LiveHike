import Foundation
import CoreLocation


struct WrongTurnPin: Identifiable, Codable {
    var id = UUID()
    let description: String
    let trailId: String
    let landmarks: String
    let latitude: Double
    let longitude: Double
    let createdAt = Date()
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id, description, trailId, landmarks, latitude, longitude, createdAt
    }
}

import Foundation
import MapKit 


struct PinLocation: Identifiable, Codable, Equatable, Hashable { 
    let id: UUID 
    let coordinate: CLLocationCoordinate2D
    let type: PinType
    let createdAt: Date
    let createdBy: String 
    var updatedAt: Date?
    var verifiedCount: Int = 0
    var dismissedCount: Int = 0
    let trailName: String 

    enum PinType: String, Codable, CaseIterable, Identifiable {
        case hazard = "Hazard"
        case wrongTurn = "Wrong Turn"
        case wildlife = "Wildlife" 
        var id: String { self.rawValue } 
    }

    static func == (lhs: PinLocation, rhs: PinLocation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case id, type, createdAt, createdBy, updatedAt, verifiedCount, dismissedCount, trailName
        case latitude, longitude 
    }

    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, type: PinType, createdBy: String, trailName: String, createdAt: Date = Date()) {
        self.id = id
        self.coordinate = coordinate
        self.type = type
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.trailName = trailName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(PinType.self, forKey: .type)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        verifiedCount = try container.decode(Int.self, forKey: .verifiedCount)
        dismissedCount = try container.decode(Int.self, forKey: .dismissedCount)
        trailName = try container.decode(String.self, forKey: .trailName)

        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encode(verifiedCount, forKey: .verifiedCount)
        try container.encode(dismissedCount, forKey: .dismissedCount)
        try container.encode(trailName, forKey: .trailName)

        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

struct HazardPin: Identifiable, Codable {
    let id: UUID 
    let pinLocationId: UUID 
    let hazardType: String 
    let severity: String 
    let description: String
    let imageURL: String? 

    enum CodingKeys: String, CodingKey {
        case id, pinLocationId, hazardType,severity, description, imageURL
    }
}

// details for a Wrong Turn Pin
struct WrongTurnPin: Identifiable, Codable {
    let id: UUID 
    let pinLocationId: UUID 
    let description: String 
    let correctDirectionDescription: String 
    let imageURL: String? 
    var landmarks: [String] 
    var annotations: [ImageAnnotation]? 

    struct ImageAnnotation: Identifiable, Codable {
        let id = UUID()
        let x: Double 
        let y: Double
        let text: String
    }

    enum CodingKeys: String, CodingKey {
        case id, pinLocationId, description, correctDirectionDescription, imageURL, landmarks, annotations
    }
}

struct Trail: Identifiable, Codable, Hashable { 
    let id: UUID 
    let name: String
    let location: String
    let difficulty: String
    let length: Double 
    let elevationGain: Int
    let coordinates: [CLLocationCoordinate2D] 

     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }

     static func == (lhs: Trail, rhs: Trail) -> Bool {
         lhs.id == rhs.id
     }


    enum CodingKeys: String, CodingKey {
        case id, name, location, difficulty, length, elevationGain
        case coordinatesLatitudes, coordinatesLongitudes
    }

    init(id: UUID = UUID(), name: String, location: String, difficulty: String, length: Double, elevationGain: Int, coordinates: [CLLocationCoordinate2D]) {
        self.id = id
        self.name = name
        self.location = location
        self.difficulty = difficulty
        self.length = length
        self.elevationGain = elevationGain
        self.coordinates = coordinates
    }
  
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(String.self, forKey: .location)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        length = try container.decode(Double.self, forKey: .length)
        elevationGain = try container.decode(Int.self, forKey: .elevationGain)

        let latitudes = try container.decode([Double].self, forKey: .coordinatesLatitudes)
        let longitudes = try container.decode([Double].self, forKey: .coordinatesLongitudes)

        var coords: [CLLocationCoordinate2D] = []
        for i in 0..<min(latitudes.count, longitudes.count) {
            coords.append(CLLocationCoordinate2D(latitude: latitudes[i], longitude: longitudes[i]))
        }
        coordinates = coords
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(location, forKey: .location)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(length, forKey: .length)
        try container.encode(elevationGain, forKey: .elevationGain)

        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }

        try container.encode(latitudes, forKey: .coordinatesLatitudes)
        try container.encode(longitudes, forKey: .coordinatesLongitudes)
    }
}


extension CLLocationCoordinate2D: Codable {
     enum CodingKeys: String, CodingKey {
         case latitude
         case longitude
     }

     public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
         let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
         self.init(latitude: latitude, longitude: longitude)
     }

     public func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(latitude, forKey: .latitude)
         try container.encode(longitude, forKey: .longitude)
     }
 }

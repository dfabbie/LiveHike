import Foundation
import SwiftUI
import MapKit

// simulated Backend
class TrailInfoManager: ObservableObject {
    @Published var trails: [Trail] = []
    @Published var pinLocations: [PinLocation] = []
    @Published var hazardPins: [HazardPin] = []
    @Published var wrongTurnPins: [WrongTurnPin] = []

    private let userDefaults = UserDefaults.standard
    private let pinLocationsKey = "liveHikePinLocations"
    private let hazardPinsKey = "liveHikeHazardPins"
    private let wrongTurnPinsKey = "liveHikeWrongTurnPins"

    //simulate the current user
    private let username = "current_user" 

    static let shared = TrailInfoManager()

    private init() {
        loadDataFromPersistence()
        // If no data loaded , load sample data
        if pinLocations.isEmpty && trails.isEmpty {
            print("No data found, loading sample data...")
            loadSampleData()
            saveDataToPersistence() // save samples for next time 
        }
        print("TrailInfoManager initialized. Trails: \(trails.count), Pins: \(pinLocations.count)")
    }

    //Data Loading 
    private func loadSampleData() {
        // Sample trails centered around Berkeley/El Cerrito
        trails = [
            Trail(name: "Strawberry Canyon Fire Trail", location: "Berkeley Hills", difficulty: "Moderate", length: 4.3, elevationGain: 908, coordinates: [
                CLLocationCoordinate2D(latitude: 37.8772, longitude: -122.2378), 
                CLLocationCoordinate2D(latitude: 37.8820, longitude: -122.2399),
                CLLocationCoordinate2D(latitude: 37.8850, longitude: -122.2450)
            ]),
            Trail(name: "Big C Trail", location: "Berkeley", difficulty: "Easy", length: 1.5, elevationGain: 320, coordinates: [
                CLLocationCoordinate2D(latitude: 37.8726, longitude: -122.2456),
                CLLocationCoordinate2D(latitude: 37.8757, longitude: -122.2505)
            ]),
            Trail(name: "Claremont Canyon Regional Preserve", location: "Berkeley/Oakland Hills", difficulty: "Hard", length: 2.1, elevationGain: 850, coordinates: [
                CLLocationCoordinate2D(latitude: 37.8617, longitude: -122.2339),
                CLLocationCoordinate2D(latitude: 37.8640, longitude: -122.2275) // Example points
            ]),
            Trail(name: "Tilden Steam Trains Trail", location: "Tilden Park, Berkeley", difficulty: "Easy", length: 1.2, elevationGain: 150, coordinates: [
                CLLocationCoordinate2D(latitude: 37.8935, longitude: -122.2405),
                CLLocationCoordinate2D(latitude: 37.8975, longitude: -122.2430)
            ]),
            Trail(name: "El Cerrito Hillside Natural Area Loop", location: "El Cerrito", difficulty: "Easy", length: 1.8, elevationGain: 300, coordinates: [ 
                CLLocationCoordinate2D(latitude: 37.9106, longitude: -122.2982),
                CLLocationCoordinate2D(latitude: 37.9145, longitude: -122.3014),
                CLLocationCoordinate2D(latitude: 37.9120, longitude: -122.3030)
            ])
        ]

        // Sample pin locations mapped to the sample trails
        let samplePinLocations = [
            PinLocation(
                coordinate: CLLocationCoordinate2D(latitude: 37.8825, longitude: -122.2405), // Near Strawberry path
                type: .hazard, createdBy: "hiker_jane", trailName: "Strawberry Canyon Fire Trail"
            ),
            PinLocation(
                coordinate: CLLocationCoordinate2D(latitude: 37.8735, longitude: -122.2490), // Near Big C path
                type: .wrongTurn, createdBy: "hiker_bob", trailName: "Big C Trail"
            ),
             PinLocation(
                coordinate: CLLocationCoordinate2D(latitude: 37.8630, longitude: -122.2300), // Near Claremont Canyon path
                type: .hazard, createdBy: "hiker_alice", trailName: "Claremont Canyon Regional Preserve"
            ),
             PinLocation(
                 coordinate: CLLocationCoordinate2D(latitude: 37.9125, longitude: -122.3000), // Near El Cerrito Hillside path
                 type: .wildlife, createdBy: "local_resident", trailName: "El Cerrito Hillside Natural Area Loop"
             )
        ]
        self.pinLocations = samplePinLocations

        // Sample hazard pins linked to the locations
        self.hazardPins = [
            HazardPin(
                id: UUID(), pinLocationId: samplePinLocations[0].id, // Fallen Tree on Strawberry
                hazardType: "Fallen Tree", severity: "High",
                description: "Large oak blocking the main trail path. Difficult to get around.", imageURL: nil
            ),
            HazardPin(
                 id: UUID(), pinLocationId: samplePinLocations[2].id, // Mud on Claremont
                 hazardType: "Muddy Section", severity: "Medium",
                 description: "Very slippery section after Stonewall Rd entrance.", imageURL: nil
             )
        ]

        // sample wrong turn pins linked to the locations
        self.wrongTurnPins = [
            WrongTurnPin(
                id: UUID(), pinLocationId: samplePinLocations[1].id, // wrong turn on Big C
                description: "Trail fork that's easily missed. Many hikers go straight instead of bearing right.",
                correctDirectionDescription: "Bear RIGHT at the fork towards the large 'C' structure.",
                imageURL: nil, landmarks: ["Large oak tree", "Rocky outcrop"], annotations: nil
            )
        ]

         
    }

    // load data from UserDefaults
    private func loadDataFromPersistence() {
        if let pinData = userDefaults.data(forKey: pinLocationsKey),
           let decodedPins = try? JSONDecoder().decode([PinLocation].self, from: pinData) {
            self.pinLocations = decodedPins
        }

        if let hazardPinData = userDefaults.data(forKey: hazardPinsKey),
           let decodedHazardPins = try? JSONDecoder().decode([HazardPin].self, from: hazardPinData) {
            self.hazardPins = decodedHazardPins
        }

        if let wrongTurnPinData = userDefaults.data(forKey: wrongTurnPinsKey),
           let decodedWrongTurnPins = try? JSONDecoder().decode([WrongTurnPin].self, from: wrongTurnPinData) {
            self.wrongTurnPins = decodedWrongTurnPins
        }

         if let trailData = userDefaults.data(forKey: "liveHikeTrails"),
            let decodedTrails = try? JSONDecoder().decode([Trail].self, from: trailData) {
             if !decodedTrails.isEmpty { // Only load persisted trails if they exist
                 self.trails = decodedTrails
             }
         }
    }

    // save data to UserDefaults
    private func saveDataToPersistence() {
        do {
            let pinData = try JSONEncoder().encode(pinLocations)
            userDefaults.set(pinData, forKey: pinLocationsKey)

            let hazardPinData = try JSONEncoder().encode(hazardPins)
            userDefaults.set(hazardPinData, forKey: hazardPinsKey)

            let wrongTurnPinData = try JSONEncoder().encode(wrongTurnPins)
            userDefaults.set(wrongTurnPinData, forKey: wrongTurnPinsKey)

             let trailData = try JSONEncoder().encode(trails)
             userDefaults.set(trailData, forKey: "liveHikeTrails")

            print("Data saved to UserDefaults.")
        } catch {
            print("Error saving data to UserDefaults: \(error.localizedDescription)")
        }
    }


    //trail methods
    func getTrailByName(_ name: String) -> Trail? {
        return trails.first { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }
    }

    func getTrailRegion(_ trail: Trail) -> MKCoordinateRegion {
        guard !trail.coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.88, longitude: -122.25), // berkeley area default
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }

        var minLat = trail.coordinates[0].latitude
        var maxLat = trail.coordinates[0].latitude
        var minLon = trail.coordinates[0].longitude
        var maxLon = trail.coordinates[0].longitude

        for coordinate in trail.coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let latDelta = (maxLat-minLat) * 1.4
        let lonDelta = (maxLon-minLon) * 1.4
        let span = MKCoordinateSpan(
            latitudeDelta: max(latDelta, 0.01), 
            longitudeDelta: max(lonDelta, 0.01)
        )

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        return MKCoordinateRegion(center: center, span: span)
    }

    //pin location methods

    func getPinsForTrail(_ trailName: String) -> [PinLocation] {
        return pinLocations.filter { $0.trailName.localizedCaseInsensitiveCompare(trailName) == .orderedSame }
    }

    func addPinLocation(_ pin: PinLocation) {
        guard !pinLocations.contains(where: { $0.id == pin.id }) else { return }
        pinLocations.append(pin)
        saveDataToPersistence() 
    }

    func deletePinLocation(_ pin: PinLocation) {
        if pin.type == .hazard {
            hazardPins.removeAll { $0.pinLocationId == pin.id }
        } else if pin.type == .wrongTurn {
            wrongTurnPins.removeAll { $0.pinLocationId == pin.id }
        }

        // remove pin location 
        pinLocations.removeAll { $0.id == pin.id }
        saveDataToPersistence() // save 
    }

    func verifyPin(_ pin: PinLocation) {
        if let index = pinLocations.firstIndex(where: { $0.id == pin.id }) {
            pinLocations[index].verifiedCount += 1
            pinLocations[index].updatedAt = Date()
            saveDataToPersistence()
            print("Pin \(pin.id) verified. Count: \(pinLocations[index].verifiedCount)")
        }
    }

    // hazard no longer present
    func dismissPin(_ pin: PinLocation) {
        if let index = pinLocations.firstIndex(where: { $0.id == pin.id }) {
            pinLocations[index].dismissedCount += 1
            pinLocations[index].updatedAt = Date()
            print("Pin \(pin.id) removed. Count: \(pinLocations[index].dismissedCount)")

            //only apply to transient pins like hazards/wildlife
            if pinLocations[index].dismissedCount >= 2 && (pin.type == .hazard || pin.type == .wildlife) {
                 
                 // call deletePinLocation 
                 let pinToDelete = pinLocations[index]
                 deletePinLocation(pinToDelete) 
            } else {
                 saveDataToPersistence() 
            }
        }
    }


    //hazard pin detail methods

    func addHazardPin(_ hazardPin: HazardPin) {
        //don't add duplicates
        guard !hazardPins.contains(where: { $0.id == hazardPin.id }) else { return }
        hazardPins.append(hazardPin)
    }

    func getHazardPinDetails(for pinLocation: PinLocation) -> HazardPin? {
         guard pinLocation.type == .hazard else { return nil } 
        return hazardPins.first(where: { $0.pinLocationId == pinLocation.id })
    }

    //Wrong turn pin methods

    func addWrongTurnPin(_ wrongTurnPin: WrongTurnPin) {
        guard !wrongTurnPins.contains(where: { $0.id == wrongTurnPin.id }) else { return }
        wrongTurnPins.append(wrongTurnPin)
    }

    func getWrongTurnPinDetails(for pinLocation: PinLocation) -> WrongTurnPin? {
        guard pinLocation.type == .wrongTurn else { return nil } 
        return wrongTurnPins.first(where: { $0.pinLocationId == pinLocation.id })
    }

}

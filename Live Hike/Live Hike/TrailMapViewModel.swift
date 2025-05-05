import Foundation
import MapKit

class TrailMapViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var userTrackingMode: MapUserTrackingMode = .none
    
    @Published var selectedPinForDetail: PinLocation? = nil
    @Published var showingPinDetailSheet = false
    
    @Published var newPinTypeToAdd: PinLocation.PinType = .hazard
    @Published var coordinateForNewPin: CLLocationCoordinate2D? = nil
    @Published var showingAddDetailsSheet = false
    
    var isAddingHazard: Bool { showingAddDetailsSheet && newPinTypeToAdd == .hazard }
    var isAddingWrongTurn: Bool { showingAddDetailsSheet && newPinTypeToAdd == .wrongTurn }
    
    let trail: Trail?
    
    init(trail: Trail? = nil) {
        self.trail = trail
        if let trail = trail {
            self.region = TrailInfoManager.shared.getTrailRegion(trail)
        } else {
            // Berkeley area default
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.8715, longitude: -122.2730),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func selectPinForDetail(_ pin: PinLocation) {
        self.selectedPinForDetail = pin
        self.showingPinDetailSheet = true
    }
    
    func handleMapTap(coordinate: CLLocationCoordinate2D, trailName: String?) {
        guard let trailName = trailName else {
            print("Cannot add pin without a trail context.")
            return
        }
        self.coordinateForNewPin = coordinate
        self.showingAddDetailsSheet = true
    }
    
    func prepareToAddHazard() {
        self.newPinTypeToAdd = .hazard
        print("Ready to add Hazard pin. Tap on the map to set location.")
    }
    
    func prepareToAddWrongTurn() {
        self.newPinTypeToAdd = .wrongTurn
        print("Ready to add Wrong Turn pin. Tap on the map to set location.")
    }
    
    func cancelAddingPin() {
        self.coordinateForNewPin = nil
        self.showingAddDetailsSheet = false
    }
    
    func finishAddingPin() {
        self.coordinateForNewPin = nil
        self.showingAddDetailsSheet = false
    }
    
    func recenterMap() {
        if let trail = trail {
            self.region = TrailInfoManager.shared.getTrailRegion(trail)
        } else {
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.8715, longitude: -122.2730),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func cycleTrackingMode() {
        switch userTrackingMode {
        case .none:
            userTrackingMode = .follow
        case .follow:
            userTrackingMode = .followWithHeading
        case .followWithHeading:
            userTrackingMode = .none
        @unknown default:
            userTrackingMode = .none
        }
    }
}

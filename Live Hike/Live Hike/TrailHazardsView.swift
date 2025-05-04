import SwiftUI
import MapKit // Needed for PinLocation coordinate potentially

struct TrailHazardsView: View {
    let trailName: String
    @StateObject private var infoManager = TrailInfoManager.shared
    @State private var hazardPinLocations: [PinLocation] = []
    @State private var selectedPinLocation: PinLocation?

    var body: some View {
        List {
            ForEach(hazardPinLocations) { pinLocation in
                if let hazardPin = infoManager.getHazardPinDetails(for: pinLocation) {
                    HazardRow(pinLocation: pinLocation, hazardPin: hazardPin)
                        .contentShape(Rectangle()) 
                        .onTapGesture {
                            selectedPinLocation = pinLocation
                        }
                } else {
                     Text("Hazard details unavailable for pin \(pinLocation.id.uuidString.prefix(4))...")
                          .foregroundColor(.secondary)
                }
            }
            .onDelete { indexSet in
                deleteHazards(at: indexSet)
            }
        }
        .navigationTitle("\(trailName) Hazards")
        .toolbar {
             ToolbarItem(placement: .navigationBarTrailing) {
                  NavigationLink {
                      // Find the Trail object to pass to the map view
                      if let trail = infoManager.getTrailByName(trailName) {
                           TrailMapView(trail: trail)
                      } else {
                           // Handle case where trail isn't found
                           Text("Trail details not found for map.")
                      }
                  } label: {
                       Image(systemName: "map")
                  }
             }
        }
        .sheet(item: $selectedPinLocation) { pinLocation in
             //standard PinDetailView
              PinDetailView(
                  pin: pinLocation,
                  hazardPin: infoManager.getHazardPinDetails(for: pinLocation),
                  wrongTurnPin: nil, // It's a hazard, so no wrong turn details
                  onVerify: {
                      infoManager.verifyPin(pinLocation)
                      loadHazardPins()
                  },
                  onDismiss: {
                      infoManager.dismissPin(pinLocation)
                      loadHazardPins()
                  },
                  onDelete: {
                      infoManager.deletePinLocation(pinLocation)
                      loadHazardPins()
                  }
              )
        }
        .onAppear {
            loadHazardPins()
        }
        // maybe:Listen for changes from the infoManager if needed
        // .onReceive(infoManager.$pinLocations) { _ in loadHazardPins() }
        // .onReceive(infoManager.$hazardPins) { _ in loadHazardPins() }
    }

    // Helper function to load/filter hazard pins for the current trail
    private func loadHazardPins() {
        hazardPinLocations = infoManager.getPinsForTrail(trailName).filter { $0.type == .hazard }
        print("Loaded \(hazardPinLocations.count) hazard pins for \(trailName)")
    }

    // Helper function to handle deletion
    private func deleteHazards(at offsets: IndexSet) {
        let pinsToDelete = offsets.map { hazardPinLocations[$0] }

        // tell the manager to delete each one
        for pin in pinsToDelete {
            // Only allow deletion if created by current user (simulation)
            if pin.createdBy == "current_user" {
                 infoManager.deletePinLocation(pin)
            } else {
                 print("Cannot delete pin created by \(pin.createdBy)")
            
            }
        }

        // reoload the local list after deletion attempt
        loadHazardPins()
    }
}

struct HazardRow: View {
    let pinLocation: PinLocation
    let hazardPin: HazardPin
    // access the manager if needed for status updates, although detail view handles it
    // @ObservedObject private var infoManager = TrailInfoManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(hazardPin.hazardType)
                    .font(.headline)
                Spacer()
                Text(hazardPin.severity)
                    .font(.subheadline)
                    .foregroundColor(severityColor(hazardPin.severity))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(severityColor(hazardPin.severity).opacity(0.2))
                    .cornerRadius(8)
            }

            Text(hazardPin.description)
                .font(.body)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "clock")
                Text("Reported: \(pinLocation.createdAt, style: .relative) ago")
                Spacer()
                Text("V:\(pinLocation.verifiedCount)")
                Text("D:\(pinLocation.dismissedCount)")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }

    // helper function for severity color 
    private func severityColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .yellow
        default: return .gray
        }
    }
}

#Preview {
    //need to initialize TrailInfoManager with some data for preview
    let _ = TrailInfoManager.shared 
    return NavigationView {
        TrailHazardsView(trailName: "Big C Trail") // Use a trail name from sample data
    }
}

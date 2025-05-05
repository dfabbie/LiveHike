import SwiftUI
import MapKit

struct TrailMapView: View {
    @StateObject private var viewModel: TrailMapViewModel
    @StateObject private var infoManager = TrailInfoManager.shared
    
    init(trail: Trail) {
        _viewModel = StateObject(wrappedValue: TrailMapViewModel(trail: trail))
    }
    
    private var pinsForCurrentTrail: [PinLocation] {
        guard let trailName = viewModel.trail?.name else { return [] }
        return infoManager.pinLocations.filter { $0.trailName == trailName }
    }
    
    var body: some View {
        ZStack {
            TappableMapView(
                region: $viewModel.region,
                userTrackingMode: $viewModel.userTrackingMode,
                pins: pinsForCurrentTrail,
                onTapPin: { pin in
                    viewModel.selectPinForDetail(pin)
                },
                onMapTap: { coordinate in
                    viewModel.handleMapTap(coordinate: coordinate, trailName: viewModel.trail?.name)
                }
            )
            .ignoresSafeArea(edges: .top)
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: viewModel.cycleTrackingMode) {
                        Image(systemName: trackingModeIcon())
                            .padding()
                            .background(.regularMaterial)
                            .foregroundColor(.primary)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.top, 5)
                    .padding(.trailing)
                    
                    Button(action: viewModel.recenterMap) {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(.regularMaterial)
                            .foregroundColor(.primary)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.top, 5)
                    .padding(.trailing)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Spacer()
                    Button {
                        viewModel.prepareToAddHazard()
                    } label: {
                        Label("Hazard", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                    
                    Button {
                        viewModel.prepareToAddWrongTurn()
                    } label: {
                        Label("Wrong Turn", systemImage: "arrow.uturn.right.circle.fill")
                            .font(.caption.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                    Spacer()
                }
                .padding(.bottom)
            }
        }
        .navigationTitle(viewModel.trail?.name ?? "Trail Map")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showingPinDetailSheet) {
            if let pin = viewModel.selectedPinForDetail {
                PinDetailView(
                    pin: pin,
                    hazardPin: infoManager.getHazardPinDetails(for: pin),
                    wrongTurnPin: infoManager.getWrongTurnPinDetails(for: pin),
                    onVerify: {
                        infoManager.verifyPin(pin)
                    },
                    onDismiss: {
                        infoManager.dismissPin(pin)
                    },
                    onDelete: {
                        infoManager.deletePinLocation(pin)
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $viewModel.showingAddDetailsSheet, onDismiss: {
            if viewModel.coordinateForNewPin != nil {
                viewModel.coordinateForNewPin = nil
            }
        }) {
            if viewModel.isAddingHazard {
                AddHazardFormView(viewModel: viewModel)
            } else if viewModel.isAddingWrongTurn {
                AddWrongTurnFormView(viewModel: viewModel)
            } else {
                Text("Error determining which form to show.")
            }
        }
        .onReceive(infoManager.$pinLocations) { _ in }
    }
    
    func trackingModeIcon() -> String {
        switch viewModel.userTrackingMode {
        case .none: return "location.slash.fill"
        case .follow: return "location.fill"
        case .followWithHeading: return "location.north.line.fill"
        @unknown default: return "location.slash.fill"
        }
    }
}

#Preview {
    let manager = TrailInfoManager.shared
    guard let previewTrail = manager.trails.first else {
        return AnyView(Text("Error: No sample trails available for preview."))
    }
    return NavigationView {
        TrailMapView(trail: previewTrail)
    }
}

import SwiftUI
import MapKit

struct PinDetailView: View {
    let pin: PinLocation
    let hazardPin: HazardPin?
    let wrongTurnPin: WrongTurnPin?
    
    let onVerify: () -> Void
    let onDismiss: () -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var canDelete: Bool {
        return pin.createdBy == "current_user"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: iconForPinType(pin.type))
                            .font(.title)
                            .foregroundColor(colorForPinType(pin.type))
                        
                        Text("\(pin.type.rawValue) Report")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Label("\(pin.verifiedCount)", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            if pin.type == .hazard || pin.type == .wildlife {
                                Label("\(pin.dismissedCount)", systemImage: "xmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if let hazard = hazardPin {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Hazard Type:", value: hazard.hazardType)
                            DetailRow(label: "Severity:", value: hazard.severity, color: severityColor(hazard.severity))
                            Text("Description:").bold()
                            Text(hazard.description)
                                .padding(.bottom, 4)
                            
                            if let imageURL = hazard.imageURL, !imageURL.isEmpty {
                                Text("Image Attached (placeholder)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    if let wrongTurn = wrongTurnPin {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Issue Description:").bold()
                            Text(wrongTurn.description)
                                .padding(.bottom, 4)
                            
                            Text("Correct Direction:").bold()
                            Text(wrongTurn.correctDirectionDescription)
                                .padding(.bottom, 4)
                            
                            if !wrongTurn.landmarks.isEmpty {
                                Text("Landmarks:").bold()
                                ForEach(wrongTurn.landmarks, id: \.self) { landmark in
                                    Label(landmark, systemImage: "mappin.and.ellipse")
                                }
                                .padding(.bottom, 4)
                            }
                            
                            if let imageURL = wrongTurn.imageURL, !imageURL.isEmpty {
                                Text("Reference Image Attached (placeholder)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    if pin.type == .wildlife {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Wildlife Sighting Details")
                                .font(.headline)
                            Text("Details: (No specific model - info TBD)")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "Reported by:", value: pin.createdBy)
                        DetailRow(label: "Reported:", value: pin.createdAt.formatted(date: .abbreviated, time: .shortened))
                        if let updated = pin.updatedAt {
                            DetailRow(label: "Last activity:", value: updated.formatted(date: .abbreviated, time: .shortened))
                        }
                        DetailRow(label: "Coordinates:", value: "\(pin.coordinate.latitude, specifier: "%.5f"), \(pin.coordinate.longitude, specifier: "%.5f")")
                    }
                    .font(.caption)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(spacing: 12) {
                        Button {
                            onVerify()
                            let feedback = UINotificationFeedbackGenerator()
                            feedback.notificationOccurred(.success)
                        } label: {
                            Label("Verify This Report", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        if pin.type == .hazard || pin.type == .wildlife {
                            Button {
                                onDismiss()
                                let feedback = UINotificationFeedbackGenerator()
                                feedback.notificationOccurred(.success)
                            } label: {
                                Label("Report No Longer Issue", systemImage: "xmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                        
                        if canDelete {
                            Button(role: .destructive) {
                                onDelete()
                                dismiss()
                            } label: {
                                Label("Delete My Report", systemImage: "trash.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("\(pin.type.rawValue) Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    struct DetailRow: View {
        let label: String
        let value: String
        var color: Color = .secondary
        
        var body: some View {
            HStack {
                Text(label)
                Spacer()
                Text(value)
                    .foregroundColor(color)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private func iconForPinType(_ type: PinLocation.PinType) -> String {
        switch type {
        case .hazard: return "exclamationmark.triangle.fill"
        case .wrongTurn: return "arrow.uturn.right.circle.fill"
        case .wildlife: return "pawprint.fill"
        }
    }
    
    private func colorForPinType(_ type: PinLocation.PinType) -> Color {
        switch type {
        case .hazard: return .red
        case .wrongTurn: return .blue
        case .wildlife: return .orange
        }
    }
    
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
    let manager = TrailInfoManager.shared
    guard let samplePin = manager.pinLocations.first(where: { $0.type == .hazard }) ?? manager.pinLocations.first else {
        return AnyView(Text("Need sample data in TrailInfoManager for preview"))
    }
    
    let hazardDetails = manager.getHazardPinDetails(for: samplePin)
    let wrongTurnDetails = manager.getWrongTurnPinDetails(for: samplePin)
    
    return PinDetailView(
        pin: samplePin,
        hazardPin: hazardDetails,
        wrongTurnPin: wrongTurnDetails,
        onVerify: { },
        onDismiss: { },
        onDelete: { }
    )
}

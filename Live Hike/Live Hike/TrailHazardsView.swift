import SwiftUI

struct Hazard: Identifiable, Codable {
    let id = UUID()
    let type: String
    let severity: String
    let description: String
    let reportedDate: Date
    let status: String
    let trailName: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, severity, description, reportedDate, status, trailName
    }
}

struct TrailHazardsView: View {
    let trailName: String
    @State private var selectedHazard: Hazard?
    @State private var showingAddHazard = false
    @State private var hazards: [Hazard] = []
    @State private var newHazardType = ""
    @State private var newHazardSeverity = "Medium"
    @State private var newHazardDescription = ""
    @State private var newHazardStatus = "Active"
    
    let severityOptions = ["Low", "Medium", "High"]
    let statusOptions = ["Active", "Resolved", "Under Review"]
    
    var body: some View {
        List {
            ForEach(hazards) { hazard in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(hazard.type)
                            .font(.headline)
                        Spacer()
                        Text(hazard.severity)
                            .font(.subheadline)
                            .foregroundColor(severityColor(hazard.severity))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(severityColor(hazard.severity).opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Text(hazard.description)
                        .font(.body)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text(hazard.reportedDate, style: .relative)
                        Spacer()
                        Text(hazard.status)
                            .foregroundColor(statusColor(hazard.status))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("\(trailName) Hazards")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddHazard = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddHazard) {
            NavigationView {
                Form {
                    Section(header: Text("Hazard Details")) {
                        TextField("Type (e.g., Rockfall, Wildlife)", text: $newHazardType)
                        
                        Picker("Severity", selection: $newHazardSeverity) {
                            ForEach(severityOptions, id: \.self) { severity in
                                Text(severity)
                            }
                        }
                        
                        TextField("Description", text: $newHazardDescription, axis: .vertical)
                            .lineLimit(3...6)
                        
                        Picker("Status", selection: $newHazardStatus) {
                            ForEach(statusOptions, id: \.self) { status in
                                Text(status)
                            }
                        }
                    }
                }
                .navigationTitle("Add Hazard")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingAddHazard = false
                    },
                    trailing: Button("Add") {
                        addHazard()
                    }
                    .disabled(newHazardType.isEmpty || newHazardDescription.isEmpty)
                )
            }
        }
        .onAppear {
            loadHazards()
        }
    }
    
    private func addHazard() {
        let newHazard = Hazard(
            type: newHazardType,
            severity: newHazardSeverity,
            description: newHazardDescription,
            reportedDate: Date(),
            status: newHazardStatus,
            trailName: trailName
        )
        
        hazards.append(newHazard)
        saveHazards()
        
        // Reset form
        newHazardType = ""
        newHazardSeverity = "Medium"
        newHazardDescription = ""
        newHazardStatus = "Active"
        
        showingAddHazard = false
    }
    
    private func loadHazards() {
        // Load sample hazards for this trail
        hazards = [
            Hazard(type: "Rockfall", severity: "High", description: "Recent rockfall reported near mile marker 2.5. Use caution.", reportedDate: Date().addingTimeInterval(-7200), status: "Active", trailName: trailName),
            Hazard(type: "Wildlife", severity: "Medium", description: "Bear sighting reported in the area. Keep food properly stored.", reportedDate: Date().addingTimeInterval(-18000), status: "Active", trailName: trailName),
            Hazard(type: "Weather", severity: "Medium", description: "Heavy rain expected in the next 3 hours. Flash flood warning.", reportedDate: Date().addingTimeInterval(-86400), status: "Active", trailName: trailName),
            Hazard(type: "Trail Condition", severity: "Low", description: "Muddy conditions on the north section of the trail.", reportedDate: Date().addingTimeInterval(-172800), status: "Active", trailName: trailName),
            Hazard(type: "Bridge Out", severity: "High", description: "Bridge crossing at mile 4.5 is temporarily closed for repairs.", reportedDate: Date().addingTimeInterval(-259200), status: "Active", trailName: trailName)
        ]
    }
    
    private func saveHazards() {
        // In a real app, this would save to a database or cloud storage
        // For now, we'll just keep them in memory
    }
    
    private func severityColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .yellow
        default: return .gray
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .red
        case "resolved": return .green
        case "under review": return .orange
        default: return .gray
        }
    }
}

#Preview {
    NavigationView {
        TrailHazardsView(trailName: "Pacific Crest Trail")
    }
} 

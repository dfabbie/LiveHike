import SwiftUI

struct Hazard: Identifiable {
    let id = UUID()
    let type: String
    let severity: String
    let description: String
    let reportedDate: String
    let status: String
}

struct TrailHazardsView: View {
    let trailName: String
    @State private var selectedHazard: Hazard?
    
    let sampleHazards = [
        Hazard(type: "Rockfall", severity: "High", description: "Recent rockfall reported near mile marker 2.5. Use caution.", reportedDate: "2 hours ago", status: "Active"),
        Hazard(type: "Wildlife", severity: "Medium", description: "Bear sighting reported in the area. Keep food properly stored.", reportedDate: "5 hours ago", status: "Active"),
        Hazard(type: "Weather", severity: "Medium", description: "Heavy rain expected in the next 3 hours. Flash flood warning.", reportedDate: "1 day ago", status: "Active"),
        Hazard(type: "Trail Condition", severity: "Low", description: "Muddy conditions on the north section of the trail.", reportedDate: "2 days ago", status: "Active"),
        Hazard(type: "Bridge Out", severity: "High", description: "Bridge crossing at mile 4.5 is temporarily closed for repairs.", reportedDate: "3 days ago", status: "Active")
    ]
    
    var body: some View {
        List(sampleHazards) { hazard in
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
                    Text(hazard.reportedDate)
                    Spacer()
                    Text(hazard.status)
                        .foregroundColor(.green)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("\(trailName) Hazards")
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
    NavigationView {
        TrailHazardsView(trailName: "Pacific Crest Trail")
    }
} 

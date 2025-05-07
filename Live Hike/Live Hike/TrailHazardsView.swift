import SwiftUI

import Foundation

struct Hazard: Identifiable {
    let id = UUID()
    let type: String
    let severity: String
    let description: String
    let reportedDate: String
    let status: String
    let trailName: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, severity, description, reportedDate, status, trailName
    }
}


struct TrailHazardsView: View {
    let trail: Trail

    var body: some View {
        List {
            Image(trail.mapImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding(.bottom)
                .accessibilityLabel("Trail map for \(trail.name)")
                .accessibilityHint("Shows the trail route and location")

            ForEach(trail.hazards) { hazard in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(hazard.type)
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        Text(hazard.severity)
                            .font(.subheadline)
                            .foregroundColor(severityColor(hazard.severity))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(severityColor(hazard.severity).opacity(0.2))
                            .cornerRadius(8)
                            .accessibilityLabel("Severity: \(hazard.severity)")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(hazard.type) - \(hazard.severity) severity")

                    Text(hazard.description)
                        .font(.body)
                        .accessibilityLabel("Description: \(hazard.description)")

                    HStack {
                        Image(systemName: "clock")
                            .accessibilityHidden(true)
                        Text(hazard.reportedDate)
                        Spacer()
                        Text(hazard.status)
                            .foregroundColor(.green)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Reported \(hazard.reportedDate), Status: \(hazard.status)")
                }
                .padding(.vertical, 6)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Hazard: \(hazard.type). \(hazard.description). Reported \(hazard.reportedDate). Status: \(hazard.status)")
            }
        }
        .navigationTitle("\(trail.name) Hazards")
        .accessibilityLabel("Hazards for \(trail.name)")
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




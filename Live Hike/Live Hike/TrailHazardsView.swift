import SwiftUI

import Foundation

struct Hazard: Identifiable {
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
    let trail: Trail

    var body: some View {
        List {
            Image(trail.mapImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding(.bottom)

            ForEach(trail.hazards) { hazard in
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
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("\(trail.name) Hazards")
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


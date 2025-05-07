import SwiftUI

struct Trail: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let difficulty: String
    let length: String
    let elevation: String
    let imageName: String
    let mapImageName: String
    let hazards: [Hazard]
}



import SwiftUI

struct SearchTrailsView: View {
    @State private var searchText = ""

    let sampleTrails: [Trail] = [
        Trail(
            name: "Mount Rainier Summit",
            location: "Washington, USA",
            difficulty: "Hard",
            length: "8.5 miles",
            elevation: "4,392 ft",
            imageName: "rainier",
            mapImageName: "rainier_map",
            hazards: [
                Hazard(type: "Avalanche", severity: "High", description: "Fresh snowpack unstable above 6,000ft.", reportedDate: "3 hours ago", status: "Active", trailName: "Mount Rainier Summit")
            ]
        ),
        Trail(
            name: "Pacific Crest Trail",
            location: "California, USA",
            difficulty: "Moderate",
            length: "7.2 miles",
            elevation: "2,700 ft",
            imageName: "pct",
            mapImageName: "pct_map",
            hazards: [
                Hazard(type: "Wildfire", severity: "High", description: "Smoke visible near the southern section.", reportedDate: "1 hour ago", status: "Active", trailName: "Pacific Crest Trail")
            ]
        ),
        Trail(
            name: "Grizzly Peak Trail",
            location: "Berkeley Hills, CA",
            difficulty: "Moderate",
            length: "4.3 miles",
            elevation: "1,200 ft",
            imageName: "grizzlypeak",
            mapImageName: "grizzlypeak_map",
            hazards: [
                Hazard(type: "Wildfire Risk", severity: "High", description: "Dry vegetation and recent heat wave increase fire danger.", reportedDate: "Today", status: "Active", trailName: "Grizzly Peak Trail"),
                Hazard(type: "Loose Gravel", severity: "Low", description: "Loose gravel on steep turns near the summit area.", reportedDate: "2 days ago", status: "Active", trailName: "Grizzly Peak Trail")
            ]
        ),
        Trail(
            name: "Tilden Park Lake Anza Loop",
            location: "Berkeley, CA",
            difficulty: "Easy",
            length: "2.1 miles",
            elevation: "300 ft",
            imageName: "lakeanza",
            mapImageName: "lakeanza_map",
            hazards: [
                Hazard(type: "Wildlife", severity: "Medium", description: "Coyote sightings reported near trailhead. Keep pets leashed.", reportedDate: "Yesterday", status: "Active", trailName: "Tilden Park Lake Anza Loop"),
                Hazard(type: "Trail Condition", severity: "Low", description: "Some muddy sections after recent rain.", reportedDate: "3 days ago", status: "Active", trailName: "Tilden Park Lake Anza Loop")
            ]
        ),
        Trail(
            name: "Claremont Canyon Fire Trail",
            location: "Berkeley, CA",
            difficulty: "Moderate",
            length: "3.5 miles",
            elevation: "1,000 ft",
            imageName: "claremontcanyon",
            mapImageName: "claremontcanyon_map",
            hazards: [
                Hazard(type: "Heat Warning", severity: "Medium", description: "Temperatures expected to reach 95°F. Bring extra water.", reportedDate: "Today", status: "Active", trailName: "Claremont Canyon Fire Trail"),
                Hazard(type: "Trail Closure", severity: "High", description: "Partial closure due to downed tree near mile 1.2.", reportedDate: "4 hours ago", status: "Active", trailName: "Claremont Canyon Fire Trail")
            ]
        )
    ]

    var filteredTrails: [Trail] {
        if searchText.isEmpty {
            return sampleTrails
        } else {
            return sampleTrails.filter { trail in
                trail.name.localizedCaseInsensitiveContains(searchText) ||
                trail.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .accessibilityLabel("Search trails")
                    .accessibilityHint("Type to search for trails by name or location")

                List(filteredTrails) { trail in
                    NavigationLink(destination: TrailHazardsView(trail: trail)) {
                        VStack(alignment: .leading) {
                            Image(trail.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 350, height: 200)
                                .clipped()
                                .cornerRadius(12)
                                .accessibilityLabel("Trail image for \(trail.name)")
                                .accessibilityRemoveTraits(.isImage)

                            Text(trail.name)
                                .font(.headline)
                                .accessibilityAddTraits(.isHeader)
                            Text(trail.location)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(trail.name), located in \(trail.location)")
                        .accessibilityHint("Double tap to view trail hazards and details")
                    }
                }
                .listStyle(.plain)
                .accessibilityLabel("List of hiking trails")
            }
            .navigationTitle("Search Trails")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .accessibilityHidden(true)
            TextField("Search trails...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel("Search trails")
                .accessibilityHint("Type to search for trails by name or location")
        }
    }
}

#Preview {
    NavigationView {
        SearchTrailsView()
    }
} 

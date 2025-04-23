import SwiftUI

struct Trail: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let difficulty: String
    let length: String
    let elevation: String
}

struct SearchTrailsView: View {
    @State private var searchText = ""
    @State private var selectedTrail: Trail?
    
    let sampleTrails = [
        Trail(name: "Mount Rainier Summit", location: "Washington, USA", difficulty: "Hard", length: "8.5 miles", elevation: "4,392 ft"),
        Trail(name: "Pacific Crest Trail", location: "California, USA", difficulty: "Moderate", length: "7.2 miles", elevation: "2,700 ft"),
        Trail(name: "Grand Canyon Rim", location: "Arizona, USA", difficulty: "Easy", length: "3.5 miles", elevation: "1,000 ft"),
        Trail(name: "Banff National Park", location: "Alberta, Canada", difficulty: "Moderate", length: "6.8 miles", elevation: "2,100 ft"),
        Trail(name: "Swiss Alps Trail", location: "Switzerland", difficulty: "Hard", length: "10.2 miles", elevation: "3,800 ft")
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
        VStack {
            SearchBar(text: $searchText)
                .padding()
            
            List(filteredTrails) { trail in
                NavigationLink(destination: TrailHazardsView(trailName: trail.name)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(trail.name)
                            .font(.headline)
                        Text(trail.location)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            Label(trail.difficulty, systemImage: "figure.hiking")
                            Spacer()
                            Label(trail.length, systemImage: "figure.walk")
                            Spacer()
                            Label(trail.elevation, systemImage: "mountain.2")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Search Trails")
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search trails...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    NavigationView {
        SearchTrailsView()
    }
} 

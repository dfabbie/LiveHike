import SwiftUI

struct Trail: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let difficulty: String
    let length: String
    let elevation: String
    let imageName: String // New property for image
}

struct SearchTrailsView: View {
    @State private var searchText = ""
    
    let sampleTrails = [
        Trail(name: "Mount Rainier Summit", location: "Washington, USA", difficulty: "Hard", length: "8.5 miles", elevation: "4,392 ft", imageName: "rainier"),
        Trail(name: "Pacific Crest Trail", location: "California, USA", difficulty: "Moderate", length: "7.2 miles", elevation: "2,700 ft", imageName: "pct"),
        Trail(name: "Grand Canyon Rim", location: "Arizona, USA", difficulty: "Easy", length: "3.5 miles", elevation: "1,000 ft", imageName: "grandcanyon"),
        Trail(name: "Banff National Park", location: "Alberta, Canada", difficulty: "Moderate", length: "6.8 miles", elevation: "2,100 ft", imageName: "banff"),
        Trail(name: "Swiss Alps Trail", location: "Switzerland", difficulty: "Hard", length: "10.2 miles", elevation: "3,800 ft", imageName: "swissalps")
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
                .padding(.horizontal)

            List(filteredTrails) { trail in
                NavigationLink(destination: TrailHazardsView(trailName: trail.name)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(trail.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(10)
                        
                        Text(trail.name)
                            .font(.headline)
                        Text(trail.location)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
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
        .padding(8)
    }
}

#Preview {
    NavigationView {
        SearchTrailsView()
    }
}
//
//  ContentView.swift
//  Live Hike
//
//  Created by Rahul Pothi Vinoth on 4/23/25.
//

import SwiftUI

struct LandingView: View {
    @State private var isShowingSearch = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("yosemite")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                    )
                    .accessibilityHidden(true)
                
                VStack(spacing: 40) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 10)
                        .accessibilityLabel("Live Hike Logo")
                    
                    Spacer()
                    
                    Text("Explore the best\ntrails around the\nworld. Safely.")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: SearchTrailsView()) {
                            HStack {
                                Text("Search Trails")
                                    .font(.headline)
                                Image(systemName: "arrow.right")
                                    .accessibilityHidden(true)
                            }
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .accessibilityLabel("Search Trails")
                        .accessibilityHint("Double tap to search for hiking trails")
                        
                        NavigationLink(destination: WildlifeScannerView()) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .accessibilityHidden(true)
                                Text("Wildlife Scanner")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(width: 200)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .accessibilityLabel("Wildlife Scanner")
                        .accessibilityHint("Double tap to scan and identify wildlife")
                    }
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    LandingView()
}

import SwiftUI
import AVFoundation

struct ScanResult {
    let animalType: String
    let confidence: Double
    let safetyTips: [String]
    let timestamp: Date
}

struct WildlifeScannerView: View {
    @State private var isShowingCamera = false
    @State private var scannedImage: UIImage?
    @State private var scanResult: ScanResult?
    @State private var isAnalyzing = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let scannedImage = scannedImage {
                Image(uiImage: scannedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding()
                
                if isAnalyzing {
                    ProgressView("Analyzing image...")
                        .padding()
                } else if let result = scanResult {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scan Results")
                            .font(.title2)
                            .bold()
                        
                        HStack {
                            Text("Animal Type:")
                                .font(.headline)
                            Text(result.animalType)
                                .font(.body)
                        }
                        
                        HStack {
                            Text("Confidence:")
                                .font(.headline)
                            Text("\(Int(result.confidence * 100))%")
                                .font(.body)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Safety Tips:")
                                .font(.headline)
                            ForEach(result.safetyTips, id: \.self) { tip in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(tip)
                                }
                            }
                        }
                        
                        Text("Scanned at: \(result.timestamp.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Scan Wildlife")
                        .font(.title)
                        .bold()
                    
                    Text("Take a photo to identify wildlife and get safety tips")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Spacer()
            
            Button(action: {
                isShowingCamera = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text(scannedImage == nil ? "Take Photo" : "Scan Again")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Wildlife Scanner")
        .sheet(isPresented: $isShowingCamera) {
            CameraView(image: $scannedImage, isAnalyzing: $isAnalyzing, scanResult: $scanResult)
        }
    }
}

struct CameraView: View {
    @Binding var image: UIImage?
    @Binding var isAnalyzing: Bool
    @Binding var scanResult: ScanResult?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                Button(action: {
                    // In a real app, this would capture an image
                    // For now, we'll use a mock image and result
                    image = UIImage(systemName: "photo")
                    isAnalyzing = true
                    
                    // Simulate analysis delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isAnalyzing = false
                        scanResult = ScanResult(
                            animalType: "Black Bear",
                            confidence: 0.92,
                            safetyTips: [
                                "Maintain a safe distance of at least 100 yards",
                                "Do not approach or feed the bear",
                                "Make noise to alert the bear of your presence",
                                "If the bear approaches, stand your ground and speak firmly",
                                "Carry bear spray and know how to use it"
                            ],
                            timestamp: Date()
                        )
                        dismiss()
                    }
                }) {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        )
                }
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    NavigationView {
        WildlifeScannerView()
    }
} 
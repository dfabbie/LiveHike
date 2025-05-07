import SwiftUI
import AVFoundation
import PhotosUI

struct ScanResult: Codable {
    let name: String
    let scientificName: String?
    let isDangerous: Bool
    let dangerLevel: Int
    let isAllergen: Bool
    let description: String
    let safetyTips: [String]
    let timestamp: Date = Date()
    let confidence: Double?
    let habitat: String?
    let diet: String?
    let behavior: String?
    let conservationStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case name, scientificName, isDangerous, dangerLevel, isAllergen, description, safetyTips
        case confidence, habitat, diet, behavior, conservationStatus
    }
}

struct WildlifeScannerView: View {
    @State private var isShowingPhotoPicker = false
    @State private var scannedImage: UIImage?
    @State private var scanResult: ScanResult?
    @State private var isAnalyzing = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if let scannedImage = scannedImage {
                Image(uiImage: scannedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding()
                    .accessibilityLabel("Scanned wildlife image")
                
                if isAnalyzing {
                    ProgressView("Analyzing image...")
                        .padding()
                        .accessibilityLabel("Analyzing image")
                        .accessibilityAddTraits(.updatesFrequently)
                } else if let result = scanResult {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Scan Results")
                                .font(.title2)
                                .bold()
                                .accessibilityAddTraits(.isHeader)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(result.name)
                                        .font(.title3)
                                        .bold()
                                    if let scientificName = result.scientificName {
                                        Text(scientificName)
                                            .font(.subheadline)
                                            .italic()
                                    }
                                    if let confidence = result.confidence {
                                        Text("Confidence: \(Int(confidence * 100))%")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()

                                ZStack {
                                    Circle()
                                        .fill(dangerColor(level: result.dangerLevel))
                                        .frame(width: 36, height: 36)
                                    
                                    if result.isDangerous {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.white)
                                    } else if result.isAllergen {
                                        Image(systemName: "allergens")
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .accessibilityLabel("\(result.isDangerous ? "Dangerous" : result.isAllergen ? "Allergen" : "Safe") - \(result.dangerLevel) level")
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(result.name)\(result.scientificName != nil ? ", \(result.scientificName!)" : "")")

                            Divider()

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Description")
                                    .font(.headline)
                                    .accessibilityAddTraits(.isHeader)
                                Text(result.description)
                                    .font(.body)
                            }
                            
                            if let habitat = result.habitat {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Habitat")
                                        .font(.headline)
                                        .accessibilityAddTraits(.isHeader)
                                    Text(habitat)
                                        .font(.body)
                                }
                            }
                            
                            if let diet = result.diet {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Diet")
                                        .font(.headline)
                                        .accessibilityAddTraits(.isHeader)
                                    Text(diet)
                                        .font(.body)
                                }
                            }
                            
                            if let behavior = result.behavior {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Behavior")
                                        .font(.headline)
                                        .accessibilityAddTraits(.isHeader)
                                    Text(behavior)
                                        .font(.body)
                                }
                            }
                            
                            if let conservationStatus = result.conservationStatus {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Conservation Status")
                                        .font(.headline)
                                        .accessibilityAddTraits(.isHeader)
                                    Text(conservationStatus)
                                        .font(.body)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Safety Tips:")
                                    .font(.headline)
                                    .accessibilityAddTraits(.isHeader)
                                ForEach(result.safetyTips, id: \.self) { tip in
                                    HStack(alignment: .top) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(dangerColor(level: result.dangerLevel))
                                            .accessibilityHidden(true)
                                        Text(tip)
                                    }
                                }
                            }
                            
                            Text("Scanned at: \(result.timestamp.formatted())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .accessibilityLabel("Scanned at \(result.timestamp.formatted())")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)
                    
                    Text("Scan Wildlife")
                        .font(.title)
                        .bold()
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Select a photo to identify wildlife and get safety tips")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Spacer()
            
            Button(action: {
                isShowingPhotoPicker = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .accessibilityHidden(true)
                    Text(scannedImage == nil ? "Select Photo" : "Select Another")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .accessibilityLabel(scannedImage == nil ? "Select Photo" : "Select Another Photo")
            .accessibilityHint("Double tap to select a photo for wildlife scanning")
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Wildlife Scanner")
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPickerView(
                image: $scannedImage,
                isAnalyzing: $isAnalyzing,
                scanResult: $scanResult,
                showErrorAlert: $showErrorAlert,
                errorMessage: $errorMessage
            )
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func dangerColor(level: Int) -> Color {
        switch level {
        case 3: return Color.red
        case 2: return Color.orange
        case 1: return Color.yellow
        default: return Color.green
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isAnalyzing: Bool
    @Binding var scanResult: ScanResult?
    @Binding var showErrorAlert: Bool
    @Binding var errorMessage: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self.parent.image = image
                            self.parent.isAnalyzing = true
                            self.processImage(image)
                        }
                    }
                }
            }
        }
        
        func processImage(_ capturedImage: UIImage) {
            if let imageData = capturedImage.jpegData(compressionQuality: 0.8) {
                let base64String = imageData.base64EncodedString()
                callReagentAPI(imageBase64: base64String)
            } else {
                parent.isAnalyzing = false
                parent.errorMessage = "Failed to process image"
                parent.showErrorAlert = true
            }
        }
        
        private func callReagentAPI(imageBase64: String) {
            let apiURL = "https://noggin.rea.gent/detailed-opossum-9528?key=rg_v1_roudvtug6z0kit2yevcosg9zww4i8xwmznys_ngk"
            
            var request = URLRequest(url: URL(string: apiURL)!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody: [String: Any] = [
                "image": "data:image/jpeg;base64,\(imageBase64)"
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) {
                request.httpBody = jsonData
                
                print("Sending request to API...")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        self.parent.isAnalyzing = false
                        
                        if let error = error {
                            print("API Error: \(error.localizedDescription)")
                            self.parent.errorMessage = "API Error: \(error.localizedDescription)"
                            self.parent.showErrorAlert = true
                            return
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            print("API Response Status: \(httpResponse.statusCode)")
                        }
                        
                        guard let data = data else {
                            print("No data received from API")
                            self.parent.errorMessage = "No data received from API"
                            self.parent.showErrorAlert = true
                            return
                        }
                        
                        // Print the raw response for debugging
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("API Response: \(jsonString)")
                        }
                        
                        do {
                            let result = try JSONDecoder().decode(ScanResult.self, from: data)
                            print("Successfully decoded result: \(result)")
                            self.parent.scanResult = result
                            self.parent.dismiss()
                        } catch {
                            print("Decoding Error: \(error.localizedDescription)")
                            self.parent.errorMessage = "Error decoding response: \(error.localizedDescription)"
                            self.parent.showErrorAlert = true
                        }
                    }
                }
                
                task.resume()
            } else {
                parent.isAnalyzing = false
                parent.errorMessage = "Failed to prepare API request"
                parent.showErrorAlert = true
            }
        }
    }
}

#Preview {
    NavigationView {
        WildlifeScannerView()
    }
}

#Preview("Test Image Preview") {
    NavigationView {
        WildlifeScannerView()
            .onAppear {
                if let testImage = UIImage(named: "test") {
                    let picker = PhotoPickerView(
                        image: .constant(testImage),
                        isAnalyzing: .constant(false),
                        scanResult: .constant(nil),
                        showErrorAlert: .constant(false),
                        errorMessage: .constant("")
                    )
                    picker.makeCoordinator().processImage(testImage)
                }
            }
    }
} 

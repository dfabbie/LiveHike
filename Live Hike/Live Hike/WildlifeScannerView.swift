import SwiftUI
import AVFoundation

struct ScanResult: Codable {
    let name: String
    let scientificName: String?
    let isDangerous: Bool
    let dangerLevel: Int 
    let isAllergen: Bool
    let description: String
    let safetyTips: [String]
    let timestamp: Date = Date() 
    
    enum CodingKeys: String, CodingKey {
        case name, scientificName, isDangerous, dangerLevel, isAllergen, description, safetyTips
    }
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
                            VStack(alignment: .leading) {
                                Text(result.name)
                                    .font(.title3)
                                    .bold()
                                if let scientificName = result.scientificName {
                                    Text(scientificName)
                                    .font(.subheadline)
                                    .italic()
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
                        }

                        Divider()

                        Text(result.description)
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Safety Tips:")
                                .font(.headline)
                            ForEach(result.safetyTips, id: \.self) { tip in
                                HStack(alignment: .top) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(dangerColor(level: result.dangerLevel))
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
    func dangerColor(level: Int) -> Color {
    switch level {
    case 3: return Color.red
    case 2: return Color.orange
    case 1: return Color.yellow
    default: return Color.green
    }
}
}

struct CameraView: View {
    @Binding var image: UIImage?
    @Binding var isAnalyzing: Bool
    @Binding var scanResult: ScanResult?
    @Environment(\.dismiss) private var dismiss

    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
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
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.delegate = ImagePickerDelegate(
                        onImageSelected: { selectedImage in
                            self.processImage(selectedImage)
                        },
                        onCancel: {
                            // Do nothing on cancel
                        }
                    )
    
                    UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
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
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Move these functions INSIDE the CameraView struct
    private func processImage(_ capturedImage: UIImage) {
        image = capturedImage
        isAnalyzing = true
        
        if let imageData = capturedImage.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            callReagentAPI(imageBase64: base64String)
        } else {
            isAnalyzing = false
            errorMessage = "Failed to process image"
            showErrorAlert = true
        }
    }
    
    private func callReagentAPI(imageBase64: String) {
        let apiURL = "https://noggin.rea.gent/structural-macaw-7976?key=rg_v1_2xjec0fh5t40quqqjbk3f8wzp6duurf1loqa_ngk"
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // the request body
        let requestBody: [String: Any] = [
            "image": "data:image/jpeg;base64,\(imageBase64)"
        ]
        
        // Convert the request body to JSON data
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) {
            request.httpBody = jsonData
            
            // Create and start the task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    
                    if let error = error {
                        self.errorMessage = "Error: \(error.localizedDescription)"
                        self.showErrorAlert = true
                        return
                    }
                    
                    guard let data = data else {
                        self.errorMessage = "No data received from API"
                        self.showErrorAlert = true
                        return
                    }
                    
                    do {
                        self.scanResult = try JSONDecoder().decode(ScanResult.self, from: data)
                        self.dismiss()
                    } catch {
                        self.errorMessage = "Error decoding response: \(error.localizedDescription)"
                        self.showErrorAlert = true
                    }
                }
            }
            
            task.resume()
        } else {
            isAnalyzing = false
            errorMessage = "Failed to prepare request"
            showErrorAlert = true
        }
    }
} 

class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let onImageSelected: (UIImage) -> Void
    let onCancel: () -> Void
    
    init(onImageSelected: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.onImageSelected = onImageSelected
        self.onCancel = onCancel
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            onImageSelected(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        onCancel()
    }
}

#Preview {
    NavigationView {
        WildlifeScannerView()
    }
} 

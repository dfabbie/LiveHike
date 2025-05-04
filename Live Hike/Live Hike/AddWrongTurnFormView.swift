import SwiftUI
import MapKit
import PhotosUI 

struct AddWrongTurnFormView: View {
    @ObservedObject var viewModel: TrailMapViewModel 
    @Environment(\.dismiss) private var dismiss

    @State private var wrongTurnDescription = ""
    @State private var correctDirectionDescription = ""
    @State private var landmarks = "" 

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        NavigationView {
            Form {
                // check if we have a selected pin
                if let pin = viewModel.selectedPin, pin.type == .wrongTurn {
                    Section(header: Text("Wrong Turn Details")) {
                         Text("Location: \(pin.coordinate.latitude, specifier: "%.5f"), \(pin.coordinate.longitude, specifier: "%.5f")")
                             .font(.caption)
                             .foregroundColor(.gray)

                        TextField("Description (What's confusing here?)", text: $wrongTurnDescription, axis: .vertical)
                            .lineLimit(3...6)

                        TextField("Correct Direction / Instructions", text: $correctDirectionDescription, axis: .vertical)
                            .lineLimit(3...6)

                        TextField("Landmarks (e.g., Big rock, Fallen log)", text: $landmarks)
                             .lineLimit(1...) 
                    }

                    // photo section
                    Section(header: Text("Add Reference Photo (Optional)")) {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images, 
                            photoLibrary: .shared()
                        ) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text(selectedImageData == nil ? "Select Photo" : "Change Photo")
                            }
                        }
                        .onChange(of: selectedPhotoItem) { 
                            Task {
                                selectedImageData = nil
                                if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                        if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200) 
                                .cornerRadius(8)
                                .padding(.vertical)
                             Button("Remove Photo", role: .destructive) {
                                 selectedPhotoItem = nil
                                 selectedImageData = nil
                             }
                        }
                    }

                } else {
                     Text("No valid wrong turn pin location selected.")
                          .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Wrong Turn Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        cancelAndCleanup()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveWrongTurnDetails()
                        dismiss()
                    }
                    .disabled(isAddButtonDisabled()) 
                }
            }
        }
    }

    private func isAddButtonDisabled() -> Bool {
        guard viewModel.selectedPin != nil else { return true }
        return wrongTurnDescription.isEmpty || correctDirectionDescription.isEmpty
    }

    private func saveWrongTurnDetails() {
        guard let pin = viewModel.selectedPin, pin.type == .wrongTurn else {
            print("Cannot save details without a selected wrong turn pin location.")
            return 
        }

        let landmarkArray = landmarks.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let simulatedImageURL: String?
        if selectedImageData != nil {
            // upload data here and get a real URL
            simulatedImageURL = "user_uploaded_image_\(UUID().uuidString.prefix(8)).jpg"
            print("Simulating image associated: \(simulatedImageURL!)")
        } else {
            simulatedImageURL = nil
        }

        let wrongTurnPin = WrongTurnPin(
            id: UUID(),
            pinLocationId: pin.id, // link to the PinLocation
            description: wrongTurnDescription,
            correctDirectionDescription: correctDirectionDescription,
            imageURL: simulatedImageURL, 
            landmarks: landmarkArray,
            annotations: nil // Placeholder 
        )

        TrailInfoManager.shared.addWrongTurnPin(wrongTurnPin)

        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)

        // maybe: Clear the selected pin in the view model?
        // viewModel.selectedPin = nil
    }

     private func cancelAndCleanup() {
         if let pin = viewModel.selectedPin {
             TrailInfoManager.shared.deletePinLocation(pin)
             print("Removed temporary pin location \(pin.id)")
         }
         viewModel.selectedPin = nil 
     }
}

#Preview {
    // dummy ViewModel and PinLocation for preview
    let previewViewModel = TrailMapViewModel()
    let previewPin = PinLocation(
        coordinate: CLLocationCoordinate2D(latitude: 37.87, longitude: -122.25),
        type: .wrongTurn,
        createdBy: "preview_user",
        trailName: "Preview Trail"
    )
    previewViewModel.selectedPin = previewPin 

    return AddWrongTurnFormView(viewModel: previewViewModel)
}

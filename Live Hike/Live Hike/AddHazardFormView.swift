import SwiftUI
import MapKit
import PhotosUI 

struct AddHazardFormView: View {
    @ObservedObject var viewModel: TrailMapViewModel // access state like selectedPin
    @Environment(\.dismiss) private var dismiss

    @State private var hazardType = ""
    @State private var hazardSeverity = "Medium" // Default 
    @State private var hazardDescription = ""

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    let severityOptions = ["Low", "Medium", "High"]

    var body: some View {
        NavigationView {
            Form {
                // Check if we have a selected pin 
                if let pin = viewModel.selectedPin, pin.type == .hazard {
                    Section(header: Text("Hazard Details")) {
                        Text("Location: \(pin.coordinate.latitude, specifier: "%.5f"), \(pin.coordinate.longitude, specifier: "%.5f")")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField("Type (e.g., Rockfall, Mud)", text: $hazardType)

                        Picker("Severity", selection: $hazardSeverity) {
                            ForEach(severityOptions, id: \.self) { severity in
                                Text(severity)
                            }
                        }

                        TextField("Description", text: $hazardDescription, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    // Photo section
                    Section(header: Text("Add Photo (Optional)")) {
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
                                // reset previous image data
                                selectedImageData = nil
                                // load new image data
                                if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }

                        
                        if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200) // Limit preview size
                                .cornerRadius(8)
                                .padding(.vertical)

                             // remove selected photo
                             Button("Remove Photo", role: .destructive) {
                                 selectedPhotoItem = nil
                                 selectedImageData = nil
                             }
                        }
                    }

                } else {
                     Text("No valid hazard pin location selected.")
                          .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Hazard Details")
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
                        saveHazardDetails()
                        dismiss()
                    }
                    .disabled(isAddButtonDisabled()) // Validate input
                }
            }
        }
    }

    private func isAddButtonDisabled() -> Bool {
        guard viewModel.selectedPin != nil else { return true }
        return hazardType.isEmpty || hazardDescription.isEmpty
    }

    private func saveHazardDetails() {
        guard let pin = viewModel.selectedPin, pin.type == .hazard else {
            print("Cannot save hazard details without a selected hazard pin location.")
            return 
        }

        //simulate saving. Use a placeholder if image data exists
        let simulatedImageURL: String?
        if selectedImageData != nil {
            //upload data here and get a real URL
            simulatedImageURL = "user_uploaded_image_\(UUID().uuidString.prefix(8)).jpg"
            print("Simulating image associated: \(simulatedImageURL!)")
        } else {
            simulatedImageURL = nil
        }

        let hazardPin = HazardPin(
            id: UUID(), // generate new ID for the HazardPin detail record
            pinLocationId: pin.id, //link to the PinLocation
            hazardType: hazardType,
            severity: hazardSeverity,
            description: hazardDescription,
            imageURL: simulatedImageURL //placeholder URL 
        )

        //add the specific hazard details via the manager
        TrailInfoManager.shared.addHazardPin(hazardPin)

        //show confirmation feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)

        // consider: Clear the selected pin in the view model?
        // viewModel.selectedPin = nil
    }

    private func cancelAndCleanup() {
        // if the user cancels adding details, remove the PinLocation that was created on map tap
        if let pin = viewModel.selectedPin {
            TrailInfoManager.shared.deletePinLocation(pin)
            print("Removed temporary pin location \(pin.id)")
        }
        viewModel.selectedPin = nil //clear selection in ViewModel
    }
}

#Preview {
     // dummy ViewModel and PinLocation for preview
     let previewViewModel = TrailMapViewModel()
     let previewPin = PinLocation(
         coordinate: CLLocationCoordinate2D(latitude: 37.87, longitude: -122.25),
         type: .hazard,
         createdBy: "preview_user",
         trailName: "Preview Trail"
     )
     previewViewModel.selectedPin = previewPin 

     return AddHazardFormView(viewModel: previewViewModel)
}

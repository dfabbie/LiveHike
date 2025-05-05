import SwiftUI
import MapKit

struct TappableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var userTrackingMode: MapUserTrackingMode
    
    let pins: [PinLocation]
    let onTapPin: (PinLocation) -> Void
    let onMapTap: (CLLocationCoordinate2D) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGesture)
        
        addPins(to: mapView, pins: pins)
        mapView.showsUserLocation = true
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if !mapView.region.isEqualTo(region, tolerance: 0.001) {
            mapView.setRegion(region, animated: true)
        }
        
        if mapView.userTrackingMode != userTrackingMode.mkUserTrackingMode {
            mapView.setUserTrackingMode(userTrackingMode.mkUserTrackingMode, animated: true)
        }
        
        updateAnnotations(on: mapView, newPins: pins)
    }
    
    private func addPins(to mapView: MKMapView, pins: [PinLocation]) {
        let annotations = pins.map { PinAnnotation(pinData: $0) }
        mapView.addAnnotations(annotations)
    }
    
    private func updateAnnotations(on mapView: MKMapView, newPins: [PinLocation]) {
        let currentAnnotations = mapView.annotations.compactMap { $0 as? PinAnnotation }
        let currentPinIDs = Set(currentAnnotations.compactMap { $0.pinData?.id })
        let newPinIDs = Set(newPins.map { $0.id })
        
        let annotationsToRemove = currentAnnotations.filter { annotation in
            guard let pinID = annotation.pinData?.id else { return true }
            return !newPinIDs.contains(pinID)
        }
        if !annotationsToRemove.isEmpty {
            mapView.removeAnnotations(annotationsToRemove)
        }
        
        let pinsToAdd = newPins.filter { !currentPinIDs.contains($0.id) }
        if !pinsToAdd.isEmpty {
            let annotationsToAdd = pinsToAdd.map { PinAnnotation(pinData: $0) }
            mapView.addAnnotations(annotationsToAdd)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TappableMapView
        
        init(_ parent: TappableMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            guard let pinAnnotation = annotation as? PinAnnotation else {
                return nil
            }
            
            let identifier = "PinAnnotation_\(pinAnnotation.pinData?.type.rawValue ?? "default")"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: pinAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                annotationView?.animatesWhenAdded = true
            } else {
                annotationView?.annotation = pinAnnotation
            }
            
            if let pin = pinAnnotation.pinData {
                switch pin.type {
                case .hazard:
                    annotationView?.markerTintColor = .red
                    annotationView?.glyphImage = UIImage(systemName: "exclamationmark.triangle.fill")
                case .wrongTurn:
                    annotationView?.markerTintColor = .blue
                    annotationView?.glyphImage = UIImage(systemName: "arrow.uturn.right.circle.fill")
                case .wildlife:
                    annotationView?.markerTintColor = .orange
                    annotationView?.glyphImage = UIImage(systemName: "pawprint.fill")
                }
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let pinAnnotation = annotation as? PinAnnotation, let pin = pinAnnotation.pinData else {
                return
            }
            
            parent.onTapPin(pin)
            mapView.deselectAnnotation(annotation, animated: false)
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                if !mapView.region.isEqualTo(self.parent.region, tolerance: 0.0001) {
                    self.parent.region = mapView.region
                }
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard gesture.state == .ended else { return }
            
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            
            var didTapAnnotation = false
            for annotation in mapView.annotations {
                if let annotationView = mapView.view(for: annotation) {
                    let locationInAnnotationView = gesture.location(in: annotationView)
                    if annotationView.bounds.contains(locationInAnnotationView) {
                        if !(annotation is MKUserLocation) {
                            didTapAnnotation = true
                            break
                        }
                    }
                }
            }
            
            if !didTapAnnotation {
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                parent.onMapTap(coordinate)
            }
        }
    }
}

// pin annotation
class PinAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let pinData: PinLocation?
    
    init(pinData: PinLocation) {
        self.coordinate = pinData.coordinate
        self.title = pinData.type.rawValue
        self.subtitle = nil
        self.pinData = pinData
        super.init()
    }
}

//helpers
extension MKCoordinateRegion {
    func isEqualTo(_ otherRegion: MKCoordinateRegion, tolerance: Double) -> Bool {
        let latDiff = abs(self.center.latitude - otherRegion.center.latitude)
        let lonDiff = abs(self.center.longitude - otherRegion.center.longitude)
        let latSpanDiff = abs(self.span.latitudeDelta - otherRegion.span.latitudeDelta)
        let lonSpanDiff = abs(self.span.longitudeDelta - otherRegion.span.longitudeDelta)
        
        return latDiff < tolerance && lonDiff < tolerance && latSpanDiff < tolerance && lonSpanDiff < tolerance
    }
}

extension MapUserTrackingMode {
    var mkUserTrackingMode: MKUserTrackingMode {
        switch self {
        case .none: return .none
        case .follow: return .follow
        case .followWithHeading: return .followWithHeading
        @unknown default: return .none
        }
    }
}

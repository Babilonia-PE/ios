import CoreLocation
import MapKit

final public class LocationManager {
    
    public var didUpdateLocations: (([CLLocation]) -> Void)?
    public var didUpdateHeading: ((CLHeading) -> Void)?
    public var didChangeAuthorization: ((CLAuthorizationStatus) -> Void)?
    public var didFailWithError: ((Error) -> Void)?
    
    public var authorizationStatus: CLAuthorizationStatus { return CLLocationManager.authorizationStatus() }
    public var currentLocation: CLLocation? {
        locationManager.location
    }
    public var authorizationStatusIsGranted: Bool {
        authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }

    private let locationManagerDelegateProxy: LocationManagerDelegateProxy
    private let locationManager: CLLocationManager
    
    public init() {
        locationManagerDelegateProxy = LocationManagerDelegateProxy()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.delegate = locationManagerDelegateProxy
        setupLocationManagerCallbacks()
    }
    
    // MARK: - Public

    public func setHeadingUpdatesEnabled(_ isEnabled: Bool) {
        isEnabled ? locationManager.startUpdatingHeading() : locationManager.stopUpdatingHeading()
    }
    
    public func setLocationUpdatesEnabled(_ isEnabled: Bool) {
        isEnabled ? locationManager.startUpdatingLocation() : locationManager.stopUpdatingLocation()
    }

    public func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func updateCurrentLocation() {
        locationManager.requestLocation()
    }
    
    public func receiveTitle(for location: CLLocationCoordinate2D, completion: @escaping ((String?) -> Void)) {
        let geocoder = CLGeocoder()
        
        geocoder
            .reverseGeocodeLocation(
                CLLocation(latitude: location.latitude, longitude: location.longitude)
            ) { (placemarks, error) in
                guard error == nil else {
                    completion(nil)
                    return
                }
                completion((placemarks?[0]).flatMap(String.init))
            }
    }

    public func openDirectionInMap(sourceCoordinate: CLLocationCoordinate2D,
                                   destinationCoordinate: CLLocationCoordinate2D,
                                   name: String) {
        let regionDistance: CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegion(center: destinationCoordinate,
                                            latitudinalMeters: regionDistance,
                                            longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ] as [String: Any]

        let placemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)

    }

    // MARK: - Private
    
    private func setupLocationManagerCallbacks() {
        locationManagerDelegateProxy.didChangeAuthorization = { [weak self] status in
            self?.didChangeAuthorization?(status)
        }
        
        locationManagerDelegateProxy.didUpdateLocations = { [weak self] locations in
            self?.didUpdateLocations?(locations)
        }
        
        locationManagerDelegateProxy.didFailWithError = { [weak self] error in
            self?.didFailWithError?(error)
        }

        locationManagerDelegateProxy.didUpdateHeading = { [weak self] heading in
            self?.didUpdateHeading?(heading)
        }
    }
    
}

private class LocationManagerDelegateProxy: NSObject, CLLocationManagerDelegate {
    
    var didUpdateLocations: (([CLLocation]) -> Void)?
    var didChangeAuthorization: ((CLAuthorizationStatus) -> Void)?
    var didFailWithError: ((Error) -> Void)?
    var didUpdateHeading: ((CLHeading) -> Void)?
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        didUpdateHeading?(newHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorization?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations?(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError?(error)
    }
    
}

private extension String {
    
    init?(placemark: CLPlacemark) {
        let elements: [String?]
        if placemark.name != nil {
            elements = [placemark.name, placemark.locality, placemark.subLocality, placemark.country]
        } else {
            elements = [placemark.locality, placemark.subLocality, placemark.country]
        }
        
        let address = elements.compactMap { $0 }.joined(separator: ", ")
        
        if !address.isEmpty {
            self = address
        } else {
            return nil
        }
    }

}

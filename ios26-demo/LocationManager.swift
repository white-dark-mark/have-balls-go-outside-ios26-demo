//
//  LocationManager.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var hasInitializedLocation = false // Track if we've set initial location
    
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 44.7866, longitude: 20.4489), // Default to Belgrade, Serbia
        span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4) // Show whole city
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Start location services on app load
        initializeLocation()
    }
    
    private func initializeLocation() {
        print("📍 Initializing location services...")
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            print("📍 Location not authorized, requesting permission...")
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        print("📍 Requesting current location...")
        locationManager.requestLocation()
    }
    
    func centerOnUserLocation() {
        guard let location = location else {
            // If no location available and permission denied, fallback to Belgrade
            if authorizationStatus == .denied || authorizationStatus == .restricted {
                print("📍 Location access denied, centering on Belgrade")
                centerOnBelgrade()
                return
            }
            
            // Otherwise, request location first
            requestLocation()
            print("📍 No location available, requesting location...")
            return
        }
        
        print("📍 Centering on user location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    func centerOnBelgrade() {
        print("📍 Centering on Belgrade, Serbia")
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 44.7866, longitude: 20.4489),
                span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
            )
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = location
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // Auto-center on user location only once when app loads
            if !self.hasInitializedLocation {
                print("📍 Auto-centering on user location (app load)")
                self.hasInitializedLocation = true
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error: \(error.localizedDescription)")
        
        // Handle common location errors
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("📍 Location is currently unknown, but Core Location will keep trying")
            case .denied:
                print("📍 Location services are disabled - staying on Belgrade")
                DispatchQueue.main.async {
                    self.hasInitializedLocation = true
                }
            case .network:
                print("📍 Network error when trying to get location")
            default:
                print("📍 Other location error: \(clError.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("📍 Location access granted, requesting current location")
                self.requestLocation()
            case .denied, .restricted:
                print("📍 Location access denied or restricted - staying on Belgrade")
                // Mark as initialized so we don't keep trying to center on user location
                self.hasInitializedLocation = true
            case .notDetermined:
                print("📍 Location permission not determined, requesting authorization")
                self.locationManager.requestWhenInUseAuthorization()
            @unknown default:
                print("📍 Unknown authorization status")
                self.hasInitializedLocation = true
                break
            }
        }
    }
} 
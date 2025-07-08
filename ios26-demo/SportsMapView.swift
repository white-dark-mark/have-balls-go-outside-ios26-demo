//
//  SportsMapView.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - MKCoordinateRegion Extension
extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return abs(lhs.center.latitude - rhs.center.latitude) < 0.0001 &&
               abs(lhs.center.longitude - rhs.center.longitude) < 0.0001 &&
               abs(lhs.span.latitudeDelta - rhs.span.latitudeDelta) < 0.0001 &&
               abs(lhs.span.longitudeDelta - rhs.span.longitudeDelta) < 0.0001
    }
}

struct SportsMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var venueSearchManager = VenueSearchManager()
    @StateObject private var translationManager = TranslationManager.shared
    @State private var selectedVenue: SportsVenue?
    @State private var showingVenueDetail = false
    @State private var showingRegistration = false
    @State private var showingLanguagePicker = false
    @State private var hasPerformedInitialSearch = false
    @State private var lastSearchLocation: CLLocation?
    @State private var searchDebounceTimer: Timer?
    
    private var venues: [SportsVenue] {
        venueSearchManager.venues.isEmpty ? SportsVenue.fallbackVenues : venueSearchManager.venues
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: venues) { venue in
                    MapAnnotation(coordinate: venue.coordinate) {
                        VenueMapMarker(venue: venue) {
                            selectedVenue = venue
                            showingVenueDetail = true
                        }
                    }
                }
                .ignoresSafeArea()


                
                // Floating action buttons
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            // Register button
                            Button(action: {
                                showingRegistration = true
                            }) {
                                Image(systemName: "person.badge.plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .purple]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            // Language picker button
                            Button(action: {
                                showingLanguagePicker = true
                            }) {
                                Image(systemName: "globe")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            
                            // Center on user location button
                            Button(action: {
                                locationManager.centerOnUserLocation()
                            }) {
                                Image(systemName: locationManager.location != nil ? "location.fill" : "location")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(locationManager.location != nil ? Color.blue : Color.gray)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .disabled(locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Bottom status bar
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(venueSearchManager.searchLocationName.isEmpty ? "Loading..." : venueSearchManager.searchLocationName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            let venueCount = venueSearchManager.venues.count
                            let venueText = venueCount == 1 ? translationManager.translate("venue") : translationManager.translate("venues")
                            Text("\(venueCount) \(venueText) found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if false {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                    
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingVenueDetail) {
                if let venue = selectedVenue {
                    VenueDetailView(venue: venue)
                }
            }
            .sheet(isPresented: $showingRegistration) {
                RegistrationView()
            }
            .sheet(isPresented: $showingLanguagePicker) {
                LanguagePickerView()
            }
            .onAppear {
                // Location is automatically initialized in LocationManager
                print("📍 Sports map view appeared")
                
                // Perform initial search after a short delay to let location initialize
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if !hasPerformedInitialSearch {
                        searchForVenues()
                        hasPerformedInitialSearch = true
                    }
                }
            }
            .onChange(of: locationManager.location) { newLocation in
                // Search for venues when location changes (but only after initial search)
                if hasPerformedInitialSearch, let _ = newLocation {
                    print("📍 Location changed, searching for venues in current viewport")
                    venueSearchManager.searchVenuesInRegion(region: locationManager.region)
                }
            }
            .onChange(of: locationManager.region) { newRegion in
                // Search for venues when map region changes (user pans/zooms the map)
                if hasPerformedInitialSearch {
                    searchVenuesForMapRegion(region: newRegion)
                }
            }
            .onDisappear {
                // Clean up timer when view disappears
                searchDebounceTimer?.invalidate()
                searchDebounceTimer = nil
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func searchForVenues() {
        print("🔍 Searching for venues in current map viewport")
        venueSearchManager.searchVenuesInRegion(region: locationManager.region)
        lastSearchLocation = CLLocation(latitude: locationManager.region.center.latitude, longitude: locationManager.region.center.longitude)
    }
    
    private func searchVenuesForMapRegion(region: MKCoordinateRegion) {
        let mapCenter = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        
        // Check if we've moved far enough to warrant a new search (1km threshold)
        if let lastLocation = lastSearchLocation {
            let distance = mapCenter.distance(from: lastLocation)
            if distance < 1000 { // Less than 1km, don't search again
                return
            }
        }
        
        // Cancel any existing timer
        searchDebounceTimer?.invalidate()
        
        // Start a new timer to debounce the search (wait 1 second after user stops moving)
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            DispatchQueue.main.async {
                print("🗺️ Searching for venues in map viewport: \(region.center) with span: \(region.span)")
                self.venueSearchManager.searchVenuesInRegion(region: region)
                self.lastSearchLocation = mapCenter
            }
        }
    }
}

struct VenueMapMarker: View {
    let venue: SportsVenue
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Text(venue.sportIcon)
                    .font(.title2)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                
                // Pointer
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .offset(y: -2)
            }
        }
        .scaleEffect(0.8)
    }
}

struct VenueDetailView: View {
    let venue: SportsVenue
    @Environment(\.dismiss) private var dismiss
    @StateObject private var translationManager = TranslationManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Text(venue.sportIcon)
                            .font(.system(size: 60))
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                            )
                        
                        VStack(spacing: 8) {
                            Text(venue.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(translationManager.translate(venue.sport))
                                .font(.title2)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Details
                    VStack(spacing: 16) {
                        InfoRow(icon: "location.fill", title: translationManager.translate("address"), value: venue.address)
                        InfoRow(icon: "info.circle.fill", title: translationManager.translate("description"), value: venue.description)
                    }
                    .padding(.horizontal, 20)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            // Open in Maps app
                            let coordinate = venue.coordinate
                            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                            mapItem.name = venue.name
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                        }) {
                            Label(translationManager.translate("get_directions"), systemImage: "map.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Placeholder for booking/joining functionality
                        }) {
                            Label(translationManager.translate("join_game"), systemImage: "person.2.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(translationManager.translate("venue_details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(translationManager.translate("done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    SportsMapView()
} 

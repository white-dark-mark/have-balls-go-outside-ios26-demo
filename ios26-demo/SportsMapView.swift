//
//  SportsMapView.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct SportsMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var translationManager = TranslationManager.shared
    @State private var selectedVenue: SportsVenue?
    @State private var showingVenueDetail = false
    @State private var showingRegistration = false
    @State private var showingLanguagePicker = false
    
    private let venues = SportsVenue.sampleVenues
    
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
            }
            .navigationTitle("sports_venues".t)
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
                            
                            Text(venue.sport.t)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Details
                    VStack(spacing: 16) {
                        InfoRow(icon: "location.fill", title: "address".t, value: venue.address)
                        InfoRow(icon: "info.circle.fill", title: "description".t, value: venue.description)
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
                            Label("get_directions".t, systemImage: "map.fill")
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
                            Label("join_game".t, systemImage: "person.2.fill")
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
            .navigationTitle("venue_details".t)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".t) {
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
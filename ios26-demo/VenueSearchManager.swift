//
//  VenueSearchManager.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import Foundation
import MapKit
import CoreLocation
import Combine

class VenueSearchManager: ObservableObject {
    @Published var venues: [SportsVenue] = []
    @Published var isSearching = false
    @Published var searchError: String?
    @Published var lastSearchLocation: CLLocation?
    @Published var searchLocationName: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    // Sport-related search terms for Apple Maps
    private let sportSearchTerms = [
        "gym", "fitness center", "sports club", "tennis court", "basketball court",
        "football field", "soccer field", "swimming pool", "sports center",
        "athletic facility", "recreation center", "sports complex", "stadium",
        "arena", "golf course", "bowling alley", "martial arts", "yoga studio",
        "boxing gym", "volleyball court", "baseball field", "hockey rink",
        "skating rink", "track and field", "climbing gym", "dance studio"
    ]
    
    // New method to search venues within a map region (viewport-based)
    func searchVenuesInRegion(region: MKCoordinateRegion) {
        let centerLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        print("🔍 Starting search for sport venues in region: \(region.center) with span: \(region.span)")
        
        isSearching = true
        searchError = nil
        venues.removeAll()
        lastSearchLocation = centerLocation
        
        // Update location name using reverse geocoding
        updateLocationName(for: centerLocation)
        
        let searchGroup = DispatchGroup()
        var allResults: [SportsVenue] = []
        
        // Search for multiple sport-related terms
        for searchTerm in sportSearchTerms.prefix(8) { // Limit to 8 terms to avoid too many requests
            searchGroup.enter()
            
            performRegionSearch(for: searchTerm, in: region) { [weak self] results in
                defer { searchGroup.leave() }
                
                guard let self = self else { return }
                
                switch results {
                case .success(let venues):
                    allResults.append(contentsOf: venues)
                case .failure(let error):
                    print("⚠️ Search failed for '\(searchTerm)': \(error.localizedDescription)")
                }
            }
        }
        
        searchGroup.notify(queue: .main) {
            // Remove duplicates based on name and location proximity
            let uniqueVenues = self.removeDuplicates(from: allResults)
            
            // Sort by distance from region center
            let sortedVenues = uniqueVenues.sorted { venue1, venue2 in
                let distance1 = centerLocation.distance(from: CLLocation(latitude: venue1.latitude, longitude: venue1.longitude))
                let distance2 = centerLocation.distance(from: CLLocation(latitude: venue2.latitude, longitude: venue2.longitude))
                return distance1 < distance2
            }
            
            self.venues = Array(sortedVenues.prefix(50)) // Limit to 50 venues
            self.isSearching = false
            
            print("🎯 Found \(self.venues.count) unique sport venues in region")
        }
    }
    
    func searchVenuesNearby(location: CLLocation) {
        print("🔍 Starting search for sport venues near: \(location.coordinate)")
        
        isSearching = true
        searchError = nil
        venues.removeAll()
        lastSearchLocation = location
        
        // Update location name using reverse geocoding
        updateLocationName(for: location)
        
        let searchGroup = DispatchGroup()
        var allResults: [SportsVenue] = []
        
        // Create a region around the location for backward compatibility
        let searchRadius: CLLocationDistance = 10000 // 10km radius for location-based search
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )
        
        // Search for multiple sport-related terms
        for searchTerm in sportSearchTerms.prefix(8) { // Limit to 8 terms to avoid too many requests
            searchGroup.enter()
            
            performRegionSearch(for: searchTerm, in: region) { [weak self] results in
                defer { searchGroup.leave() }
                
                guard let self = self else { return }
                
                switch results {
                case .success(let venues):
                    allResults.append(contentsOf: venues)
                case .failure(let error):
                    print("⚠️ Search failed for '\(searchTerm)': \(error.localizedDescription)")
                }
            }
        }
        
        searchGroup.notify(queue: .main) {
            // Remove duplicates based on name and location proximity
            let uniqueVenues = self.removeDuplicates(from: allResults)
            
            // Sort by distance from search location
            let sortedVenues = uniqueVenues.sorted { venue1, venue2 in
                let distance1 = location.distance(from: CLLocation(latitude: venue1.latitude, longitude: venue1.longitude))
                let distance2 = location.distance(from: CLLocation(latitude: venue2.latitude, longitude: venue2.longitude))
                return distance1 < distance2
            }
            
            self.venues = Array(sortedVenues.prefix(50)) // Limit to 50 venues
            self.isSearching = false
            
            print("🎯 Found \(self.venues.count) unique sport venues")
        }
    }
    
    private func performRegionSearch(for searchTerm: String, in region: MKCoordinateRegion, completion: @escaping (Result<[SportsVenue], Error>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response else {
                completion(.success([]))
                return
            }
            
            let venues = response.mapItems.compactMap { mapItem -> SportsVenue? in
                guard let placemark = mapItem.placemark.location else { return nil }
                
                // Filter to only include venues within the visible region bounds
                let coordinate = placemark.coordinate
                let regionBounds = self.getRegionBounds(region: region)
                
                guard coordinate.latitude >= regionBounds.minLat && coordinate.latitude <= regionBounds.maxLat &&
                      coordinate.longitude >= regionBounds.minLon && coordinate.longitude <= regionBounds.maxLon else {
                    return nil
                }
                
                let name = mapItem.name ?? "Unknown Venue"
                let sport = self.determineSportType(from: mapItem, searchTerm: searchTerm)
                let address = self.formatAddress(from: mapItem.placemark)
                let description = self.generateDescription(for: mapItem, sport: sport)
                
                return SportsVenue(
                    name: name,
                    sport: sport,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    address: address,
                    description: description
                )
            }
            
            completion(.success(venues))
        }
    }
    
    private func getRegionBounds(region: MKCoordinateRegion) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) {
        let center = region.center
        let span = region.span
        
        let minLat = center.latitude - span.latitudeDelta / 2
        let maxLat = center.latitude + span.latitudeDelta / 2
        let minLon = center.longitude - span.longitudeDelta / 2
        let maxLon = center.longitude + span.longitudeDelta / 2
        
        return (minLat, maxLat, minLon, maxLon)
    }
    
    // Search with default Belgrade location
    func searchVenuesInBelgrade() {
        let belgradeLocation = CLLocation(latitude: 44.7866, longitude: 20.4489)
        let belgradeRegion = MKCoordinateRegion(
            center: belgradeLocation.coordinate,
            latitudinalMeters: 20000, // 20km radius for Belgrade
            longitudinalMeters: 20000
        )
        searchVenuesInRegion(region: belgradeRegion)
    }
    
    private func determineSportType(from mapItem: MKMapItem, searchTerm: String) -> String {
        let name = mapItem.name?.lowercased() ?? ""
        let category = mapItem.pointOfInterestCategory?.rawValue.lowercased() ?? ""
        
        // Try to determine sport type from name and category
        if name.contains("tennis") || searchTerm.contains("tennis") { return "tennis" }
        if name.contains("basketball") || searchTerm.contains("basketball") { return "basketball" }
        if name.contains("football") || name.contains("soccer") || searchTerm.contains("football") || searchTerm.contains("soccer") { return "soccer" }
        if name.contains("swimming") || name.contains("pool") || searchTerm.contains("swimming") { return "swimming" }
        if name.contains("gym") || name.contains("fitness") || searchTerm.contains("gym") || searchTerm.contains("fitness") { return "gym" }
        if name.contains("golf") || searchTerm.contains("golf") { return "golf" }
        if name.contains("baseball") || searchTerm.contains("baseball") { return "baseball" }
        if name.contains("volleyball") || searchTerm.contains("volleyball") { return "volleyball" }
        if name.contains("boxing") || searchTerm.contains("boxing") { return "boxing" }
        if name.contains("martial") || searchTerm.contains("martial") { return "martial arts" }
        if name.contains("yoga") || searchTerm.contains("yoga") { return "yoga" }
        if name.contains("dance") || searchTerm.contains("dance") { return "dance" }
        if name.contains("climbing") || searchTerm.contains("climbing") { return "climbing" }
        if name.contains("bowling") || searchTerm.contains("bowling") { return "bowling" }
        if name.contains("hockey") || searchTerm.contains("hockey") { return "ice hockey" }
        if name.contains("skating") || searchTerm.contains("skating") { return "skating" }
        if name.contains("track") || searchTerm.contains("track") { return "running" }
        if name.contains("stadium") || name.contains("arena") || searchTerm.contains("stadium") || searchTerm.contains("arena") { return "soccer" }
        
        // Default based on search term
        return searchTerm == "gym" || searchTerm == "fitness center" ? "gym" : "sports"
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let street = placemark.thoroughfare,
           let number = placemark.subThoroughfare {
            addressComponents.append("\(street) \(number)")
        } else if let street = placemark.thoroughfare {
            addressComponents.append(street)
        }
        
        if let city = placemark.locality {
            addressComponents.append(city)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    private func generateDescription(for mapItem: MKMapItem, sport: String) -> String {
        let name = mapItem.name ?? "Sports venue"
        let category = mapItem.pointOfInterestCategory?.rawValue ?? ""
        
        if category.contains("Fitness") || sport == "gym" {
            return "Fitness center offering various workout equipment and training programs"
        } else if sport == "tennis" {
            return "Tennis facility with courts available for play"
        } else if sport == "swimming" {
            return "Swimming facility with pool access and aquatic programs"
        } else if sport == "soccer" || sport == "football" {
            return "Football/soccer facility with fields available for play"
        } else if sport == "basketball" {
            return "Basketball facility with courts available for play"
        } else if sport == "golf" {
            return "Golf facility with course access and equipment"
        } else {
            return "Sports facility offering \(sport) activities and programs"
        }
    }
    
    private func removeDuplicates(from venues: [SportsVenue]) -> [SportsVenue] {
        var uniqueVenues: [SportsVenue] = []
        
        for venue in venues {
            let isDuplicate = uniqueVenues.contains { existingVenue in
                // Check if names are similar or locations are very close
                let nameSimilar = existingVenue.name.lowercased() == venue.name.lowercased()
                let locationClose = abs(existingVenue.latitude - venue.latitude) < 0.001 && 
                                   abs(existingVenue.longitude - venue.longitude) < 0.001
                
                return nameSimilar || locationClose
            }
            
            if !isDuplicate {
                uniqueVenues.append(venue)
            }
        }
        
        return uniqueVenues
    }
    

    
    // Update location name using reverse geocoding
    private func updateLocationName(for location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self = self, let placemark = placemarks?.first else {
                    self?.searchLocationName = "Unknown Location"
                    return
                }
                
                // Build a readable location name
                var locationComponents: [String] = []
                
                if let neighborhood = placemark.subLocality {
                    locationComponents.append(neighborhood)
                }
                
                if let city = placemark.locality {
                    locationComponents.append(city)
                }
                
                if let country = placemark.country {
                    locationComponents.append(country)
                }
                
                self.searchLocationName = locationComponents.joined(separator: ", ")
                
                if self.searchLocationName.isEmpty {
                    self.searchLocationName = "Current Location"
                }
                
                print("📍 Search location: \(self.searchLocationName)")
            }
        }
    }
}

// MARK: - SportsVenue Extension for Apple Maps Integration
extension SportsVenue {
    // Keep the existing sample venues as fallback
    static let fallbackVenues = sampleVenues
} 
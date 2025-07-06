//
//  SportsVenue.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import Foundation
import MapKit

struct SportsVenue: Identifiable, Codable {
    let id = UUID()
    let name: String
    let sport: String
    let latitude: Double
    let longitude: Double
    let address: String
    let description: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var sportIcon: String {
        switch sport.lowercased() {
        case "soccer", "football": return "⚽"
        case "basketball": return "🏀"
        case "tennis": return "🎾"
        case "baseball": return "⚾"
        case "american football": return "🏈"
        case "volleyball": return "🏐"
        case "swimming": return "🏊"
        case "running", "track": return "🏃"
        case "cycling": return "🚴"
        case "boxing": return "🥊"
        case "martial arts": return "🥋"
        case "golf": return "⛳"
        case "ice hockey": return "🏒"
        case "skiing": return "⛷️"
        case "snowboarding": return "🏂"
        case "surfing": return "🏄"
        case "skateboarding": return "🛹"
        case "wrestling": return "🤼"
        case "weightlifting", "gym": return "🏋️"
        case "gymnastics": return "🤸"
        default: return "🏟️"
        }
    }
}

// Sample data for demonstration
extension SportsVenue {
    static let sampleVenues: [SportsVenue] = [
        // Belgrade, Serbia venues
        SportsVenue(
            name: "Rajko Mitić Stadium",
            sport: "soccer",
            latitude: 44.7831,
            longitude: 20.4668,
            address: "Ljutice Bogdana 1a, Belgrade",
            description: "Home stadium of Red Star Belgrade football club"
        ),
        SportsVenue(
            name: "Partizan Stadium",
            sport: "soccer",
            latitude: 44.7890,
            longitude: 20.4612,
            address: "Humska 1, Belgrade",
            description: "Home stadium of Partizan Belgrade football club"
        ),
        SportsVenue(
            name: "Aleksandar Nikolić Hall",
            sport: "basketball",
            latitude: 44.8125,
            longitude: 20.4656,
            address: "Čika Ljubina 8, Belgrade",
            description: "Premier basketball arena in Belgrade"
        ),
        SportsVenue(
            name: "Tašmajdan Sports Center",
            sport: "tennis",
            latitude: 44.8067,
            longitude: 20.4719,
            address: "Tašmajdan Park, Belgrade",
            description: "Public tennis courts in Tašmajdan Park"
        ),
        SportsVenue(
            name: "Kalemegdan Park Fields",
            sport: "soccer",
            latitude: 44.8225,
            longitude: 20.4487,
            address: "Kalemegdan Park, Belgrade",
            description: "Beautiful football fields in historic Kalemegdan Park"
        ),
        SportsVenue(
            name: "Ada Ciganlija Beach",
            sport: "volleyball",
            latitude: 44.7908,
            longitude: 20.4064,
            address: "Ada Ciganlija, Belgrade",
            description: "Beach volleyball courts on Belgrade's river island"
        ),
        SportsVenue(
            name: "Košutnjak Park Courts",
            sport: "basketball",
            latitude: 44.7677,
            longitude: 20.4391,
            address: "Košutnjak Park, Belgrade",
            description: "Outdoor basketball courts in Košutnjak forest"
        ),
        SportsVenue(
            name: "Sava River Running Track",
            sport: "running",
            latitude: 44.8169,
            longitude: 20.4131,
            address: "Sava River Embankment, Belgrade",
            description: "Scenic running track along the Sava River"
        ),
        SportsVenue(
            name: "Pinki Sports Complex",
            sport: "swimming",
            latitude: 44.7439,
            longitude: 20.3775,
            address: "Pinki, Belgrade",
            description: "Modern swimming pool complex"
        ),
        SportsVenue(
            name: "Voždovac Gym",
            sport: "gym",
            latitude: 44.7774,
            longitude: 20.4874,
            address: "Voždovac, Belgrade",
            description: "Popular fitness center with weightlifting facilities"
        )
    ]
} 
//
//  LocalizationHelper.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import Foundation
import SwiftUI

// MARK: - String Extension for Localization
extension String {
    /// Returns a localized version of the string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized version with arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Localized Text View
struct LocalizedText: View {
    let key: String
    let arguments: [CVarArg]
    
    init(_ key: String, arguments: CVarArg...) {
        self.key = key
        self.arguments = arguments
    }
    
    var body: some View {
        if arguments.isEmpty {
            Text(key.localized)
        } else {
            Text(key.localized(with: arguments))
        }
    }
}

// MARK: - Sports Name Helper
struct SportsLocalizer {
    static func localizedSportName(_ sport: String) -> String {
        switch sport.lowercased() {
        case "soccer", "football", "fudbal":
            return "soccer".localized
        case "basketball", "košarka":
            return "basketball".localized
        case "tennis", "tenis":
            return "tennis".localized
        case "baseball", "bejzbol":
            return "baseball".localized
        case "american football", "američki fudbal":
            return "american_football".localized
        case "volleyball", "odbojka":
            return "volleyball".localized
        case "swimming", "plivanje":
            return "swimming".localized
        case "running", "trčanje":
            return "running".localized
        case "cycling", "biciklizam":
            return "cycling".localized
        case "boxing", "boks":
            return "boxing".localized
        case "martial arts", "borilačke veštine":
            return "martial_arts".localized
        case "golf":
            return "golf".localized
        case "ice hockey", "hokej na ledu":
            return "ice_hockey".localized
        case "skiing", "skijanje":
            return "skiing".localized
        case "snowboarding", "snoubording":
            return "snowboarding".localized
        case "surfing", "surfovanje":
            return "surfing".localized
        case "skateboarding", "skejtbording":
            return "skateboarding".localized
        case "wrestling", "rvanje":
            return "wrestling".localized
        case "weightlifting", "gym", "teretana":
            return "weightlifting".localized
        case "gymnastics", "gimnastika":
            return "gymnastics".localized
        default:
            return sport
        }
    }
} 
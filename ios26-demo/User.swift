//
//  User.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import Foundation
import SwiftData

@Model
final class User {
    var phone: String
    var firstName: String
    var lastName: String
    var nickname: String
    var sports: [String]
    var cityNeighborhood: String
    
    init(phone: String, firstName: String, lastName: String, nickname: String, sports: [String], cityNeighborhood: String) {
        self.phone = phone
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.sports = sports
        self.cityNeighborhood = cityNeighborhood
    }
} 
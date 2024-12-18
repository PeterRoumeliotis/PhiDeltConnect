//  Profile.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import Foundation

// Profile is the user profile data.

struct Profile: Codable {
    var name: String
    var subtitle: String
    var about: String
    var experience: String
    var yearsInFraternity: Int
    var profilePicName: String
    var followers: [String] //Array of userIDs that follow the person
    var lookingForWorkTitle: String = "" //A field to put a job you are looking for
}

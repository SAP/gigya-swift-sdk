//
//  GigyaProfile.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 10/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct GigyaProfile: Codable {
     var firstName: String?
     var lastName: String?
     var nickName: String?
     var address: String?
     var age: Int?
     var bio: String?
     var birthDay: Int?
     var birthMonth: Int?
     var birthYear: Int?
     var capabilities: String? //Capabilities?
     var certifications: [Certification]?
     var city: String?
     var country: String?
     var education: [UserEducation]?
     var educationLevel: String?
     var email: String?
     var favorites: UserFavorites?
     var followersCount: Int?
     var followingCount: Int?
     var gender: String?
     var hometown: String?
     var honors: String?
     var identities: [ProviderIdentity]?
     var industry: String?
     var interestedIn: String?
     var interests: String?
     var isConnected: Bool?
     var iRank: Int?
     var isSiteUID: Bool?
     var isSiteUser: Bool?
     var languages: String?
     var likes: [UserLike]?
     var locale: String?
     var name: String?
     var oldestDataAge: Int?
     var oldestDataUpdatedTimestamp: Int?
     var patents: [UserPatent]?
     var phones: [UserPhone]?
     var photoURL: String?
     var providers: String?
     var publications: [UserPublication]?
     var relationshipStatus: String?
     var religion: String?
     var samlData: UserSamlData?
     var skills: [UserSkill]?
     var specialities: String?
     var state: String?
     var timezone: String?
     var thumbnailURL: String?
     var username: String?
     var isVerified: Bool?
     var verified: String?
     var verifiedTimestamp: Int?
     var work: [UserWork]?
     var zip: String?

    struct Certification: Codable {
        var name: String?
        var authority: String?
        var number: String?
        var startDate: String?
        var endDate: String?
    }

    struct UserEducation: Codable {
        var school: String?
        var schoolType: String?
        var fieldOfStudy: String?
        var degree: String?
        var startYear: String?
        var endYear: String?
    }

    // TODO: Describe favorites protocol
    struct UserFavorite: Codable {
        var id: String?
        var name: String?
        var category: String?
    }

    struct UserFavorites: Codable {
        var interests: [UserFavorite]?
        var activities: [UserFavorite]?
        var books: [UserFavorite]?
        var music: [UserFavorite]?
        var movies: [UserFavorite]?
        var television: [UserFavorite]?
    }

    // TODO: Describe provider identity protocol
    struct ProviderIdentity: Codable {}

    struct UserLike: Codable {
        var name: String?
        var category: String?
        var id: String?
        var time: String?
        var timestamp: Int?
    }

    struct UserPatent: Codable {
        var title: String?
        var summary: String?
        var number: String?
        var office: String?
        var status: String?
        var date: String?
        var url: String?
    }

    struct UserPhone: Codable {
        var type: String?
        var number: String?
    }

    struct UserPublication: Codable {
        var title: String?
        var summary: String?
        var publisher: String?
        var date: String?
        var url: String?
    }

    // TODO: describe Saml Data protocol
    struct UserSamlData: Codable {}

    struct UserSkill: Codable {
        var skill: String?
        var level: String?
        var years: String?
    }

    struct UserWork: Codable {
        var company: String?
        var companyID: String?
        var title: String?
        var companySize: String?
        var startDate: String?
        var endDate: String?
        var industry: String?
        var isCurrent: Bool?
    }

}

//public struct Capabilities: Codable {
//    var login: Bool?
//    var notifications: Bool?
//    var actions: Bool?
//    var friends: Bool?
//    var status: Bool?
//    var contacts: Bool?
//    var photos: Bool?
//}

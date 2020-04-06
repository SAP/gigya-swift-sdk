//
//  GigyaProfile.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 10/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public struct GigyaProfile: Codable {
    public var firstName: String?
    public var lastName: String?
    public var nickname: String?
    public var address: String?
    public var age: Int?
    public var bio: String?
    public var birthDay: Int?
    public var birthMonth: Int?
    public var birthYear: Int?
    public var capabilities: String? //Capabilities?
    public var certifications: [Certification]?
    public var city: String?
    public var country: String?
    public var education: [UserEducation]?
    public var educationLevel: String?
    public var email: String?
    public var favorites: UserFavorites?
    public var followersCount: Int?
    public var followingCount: Int?
    public var gender: String?
    public var hometown: String?
    public var honors: String?
    public var identities: [ProviderIdentity]?
    public var industry: String?
    public var interestedIn: String?
    public var interests: String?
    public var isConnected: Bool?
    public var iRank: Int?
    public var isSiteUID: Bool?
    public var isSiteUser: Bool?
    public var languages: String?
    public var likes: [UserLike]?
    public var locale: String?
    public var name: String?
    public var oldestDataAge: Int?
    public var oldestDataUpdatedTimestamp: Int?
    public var patents: [UserPatent]?
    public var phones: [UserPhone]?
    public var photoURL: String?
    public var providers: String?
    public var publications: [UserPublication]?
    public var relationshipStatus: String?
    public var religion: String?
    public var samlData: UserSamlData?
    public var skills: [UserSkill]?
    public var specialities: String?
    public var state: String?
    public var timezone: String?
    public var thumbnailURL: String?
    public var username: String?
    public var isVerified: Bool?
    public var verified: String?
    public var verifiedTimestamp: Int?
    public var work: [UserWork]?
    public var zip: String?

    public struct Certification: Codable {
        public var name: String?
        public var authority: String?
        public var number: String?
        public var startDate: String?
        public var endDate: String?
    }

    public struct UserEducation: Codable {
        public var school: String?
        public var schoolType: String?
        public var fieldOfStudy: String?
        public var degree: String?
        public var startYear: String?
        public var endYear: String?
    }

    // TODO: Describe favorites protocol
    public struct UserFavorite: Codable {
        public var id: String?
        public var name: String?
        public var category: String?
    }

    public struct UserFavorites: Codable {
        public var interests: [UserFavorite]?
        public var activities: [UserFavorite]?
        public var books: [UserFavorite]?
        public var music: [UserFavorite]?
        public var movies: [UserFavorite]?
        public var television: [UserFavorite]?
    }

    // TODO: Describe provider identity protocol
    public struct ProviderIdentity: Codable {}

    public struct UserLike: Codable {
        public var name: String?
        public var category: String?
        public var id: String?
        public var time: String?
        public var timestamp: Int?
    }

    public struct UserPatent: Codable {
        public var title: String?
        public var summary: String?
        public var number: String?
        public var office: String?
        public var status: String?
        public var date: String?
        public var url: String?
    }

    public struct UserPhone: Codable {
        public var type: String?
        public var number: String?
    }

    public struct UserPublication: Codable {
        public var title: String?
        public var summary: String?
        public var publisher: String?
        public var date: String?
        public var url: String?
    }

    // TODO: describe Saml Data protocol
    public struct UserSamlData: Codable {}

    public struct UserSkill: Codable {
        public var skill: String?
        public var level: String?
        public var years: String?
    }

    public struct UserWork: Codable {
        public var company: String?
        public var companyID: String?
        public var title: String?
        public var companySize: String?
        public var startDate: String?
        public var endDate: String?
        public var industry: String?
        public var isCurrent: Bool?
    }

}

//public public struct Capabilities: Codable {
//    public var login: Bool?
//    public var notifications: Bool?
//    public var actions: Bool?
//    public var friends: Bool?
//    public var status: Bool?
//    public var contacts: Bool?
//    public var photos: Bool?
//}

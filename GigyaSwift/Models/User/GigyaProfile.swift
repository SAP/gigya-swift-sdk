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

    enum CodingKeys: String, CodingKey {
        case firstName, lastName, nickname
        case age, bio, birthDay ,birthMonth, birthYear
        case capabilities
        case certifications
        case address, city, country
        case education, educationLevel
        case email
        case favorites
        case followersCount
        case followingCount
        case gender
        case hometown
        case honors
        case identities
        case industry
        case interestedIn
        case interests
        case isConnected
        case iRank
        case isSiteUID
        case isSiteUser
        case languages
        case likes
        case locale
        case name
        case oldestDataAge
        case oldestDataUpdatedTimestamp
        case patents
        case phones
        case photoURL
        case providers
        case publications
        case relationshipStatus
        case religion
        case samlData
        case skills
        case specialities
        case state
        case timezone
        case thumbnailURL
        case username
        case isVerified
        case verified
        case verifiedTimestamp
        case work
        case zip

    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.firstName = try? container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try? container.decodeIfPresent(String.self, forKey: .lastName)
        self.nickname = try? container.decodeIfPresent(String.self, forKey: .nickname)
        self.address = try? container.decodeIfPresent(String.self, forKey: .address)
        self.city = try? container.decodeIfPresent(String.self, forKey: .city)
        self.country = try? container.decodeIfPresent(String.self, forKey: .country)
        self.age = try? container.decodeIfPresent(Int.self, forKey: .age)
        self.bio = try? container.decodeIfPresent(String.self, forKey: .bio)
        self.birthDay = try? container.decodeIfPresent(Int.self, forKey: .birthDay)
        self.birthMonth = try? container.decodeIfPresent(Int.self, forKey: .birthMonth)
        self.birthYear = try? container.decodeIfPresent(Int.self, forKey: .birthYear)
        self.educationLevel = try? container.decodeIfPresent(String.self, forKey: .educationLevel)
        self.email = try? container.decodeIfPresent(String.self, forKey: .email)
        self.followersCount = try? container.decodeIfPresent(Int.self, forKey: .followersCount)
        self.followingCount = try? container.decodeIfPresent(Int.self, forKey: .followingCount)
        self.gender = try? container.decodeIfPresent(String.self, forKey: .gender)
        self.hometown = try? container.decodeIfPresent(String.self, forKey: .hometown)
        self.honors = try? container.decodeIfPresent(String.self, forKey: .honors)
        self.industry = try? container.decodeIfPresent(String.self, forKey: .industry)
        self.interestedIn = try? container.decodeIfPresent(String.self, forKey: .interestedIn)
        self.isConnected = try? container.decodeIfPresent(Bool.self, forKey: .isConnected)
        self.iRank = try? container.decodeIfPresent(Int.self, forKey: .iRank)
        self.isSiteUID = try? container.decodeIfPresent(Bool.self, forKey: .isSiteUID)
        self.isSiteUser = try? container.decodeIfPresent(Bool.self, forKey: .isSiteUser)
        self.languages = try? container.decodeIfPresent(String.self, forKey: .languages)
        self.locale = try? container.decodeIfPresent(String.self, forKey: .locale)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.oldestDataAge = try? container.decodeIfPresent(Int.self, forKey: .oldestDataAge)
        self.oldestDataUpdatedTimestamp = try? container.decodeIfPresent(Int.self, forKey: .oldestDataUpdatedTimestamp)
        self.photoURL = try? container.decodeIfPresent(String.self, forKey: .photoURL)
        self.relationshipStatus = try? container.decodeIfPresent(String.self, forKey: .relationshipStatus)
        self.religion = try? container.decodeIfPresent(String.self, forKey: .religion)
        self.samlData = try? container.decodeIfPresent(UserSamlData.self, forKey: .samlData)
        self.specialities = try? container.decodeIfPresent(String.self, forKey: .specialities)
        self.state = try? container.decodeIfPresent(String.self, forKey: .state)
        self.timezone = try? container.decodeIfPresent(String.self, forKey: .timezone)
        self.thumbnailURL = try? container.decodeIfPresent(String.self, forKey: .thumbnailURL)
        self.isVerified = try? container.decodeIfPresent(Bool.self, forKey: .isVerified)
        self.isVerified = try? container.decodeIfPresent(Bool.self, forKey: .isVerified)
        self.verified = try? container.decodeIfPresent(String.self, forKey: .verified)
        self.verifiedTimestamp = try? container.decodeIfPresent(Int.self, forKey: .verifiedTimestamp)
        self.zip = try? container.decodeIfPresent(String.self, forKey: .zip)

        self.favorites = try? container.decodeIfPresent(UserFavorites.self, forKey: .favorites)
        self.certifications = objectToArrayOnProfileField(object: Certification.self, key: .certifications, container: container)
        self.education = objectToArrayOnProfileField(object: UserEducation.self, key: .education, container: container)
        self.likes = objectToArrayOnProfileField(object: UserLike.self, key: .likes, container: container)
        self.patents = objectToArrayOnProfileField(object: UserPatent.self, key: .patents, container: container)
        self.phones = objectToArrayOnProfileField(object: UserPhone.self, key: .phones, container: container)
        self.publications = objectToArrayOnProfileField(object: UserPublication.self, key: .publications, container: container)
        self.skills = objectToArrayOnProfileField(object: UserSkill.self, key: .skills, container: container)
        self.work = objectToArrayOnProfileField(object: UserWork.self, key: .work, container: container)
        self.identities = objectToArrayOnProfileField(object: ProviderIdentity.self, key: .identities, container: container)
    }

    func objectToArrayOnProfileField<T: Codable>(object: T.Type, key: GigyaProfile.CodingKeys, container: KeyedDecodingContainer<GigyaProfile.CodingKeys>) -> [T]? {
        var array = try? container.decodeIfPresent([T].self, forKey: key)
        if array == nil {
            if let obj = try? container.decodeIfPresent(T.self, forKey: key) {
                array = Array(arrayLiteral: obj)
            }
        }

        return array
    }

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
        public var startYear: Int?
        public var endYear: Int?
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

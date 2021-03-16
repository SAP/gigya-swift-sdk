//
//  GigyaSchema.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 04/03/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation

public struct GigyaSchema: Codable {
    public let profileSchema: GigyaProfileSchema?
    public let dataSchema: GigyaDataSchema?
    public let subscriptionsSchema: GigyaSubscriptionSchema?
    public let preferencesSchema: GigyaPreferencesSchema?

    public struct GigyaProfileSchema: Codable {
        public let fields: [String: ProfileSchema]?
        public let dynamicSchema: Bool?
    }

    public struct GigyaDataSchema: Codable {
        public let fields: [String: DataSchema]?
        public let dynamicSchema: Bool?
    }

    public struct GigyaSubscriptionSchema: Codable {
        public let fields: [String: SubscriptionSchema]?
        public let dynamicSchema: Bool?
    }

    public struct GigyaPreferencesSchema: Codable {
        public let fields: [String: PreferenceSchema]?
        public let dynamicSchema: Bool?
    }

    public struct DataSchema: Codable {
        public let type: String?
        public let writeAccess: String?
        public let format: String?
        public let encrypt: String?
        public let required: Bool?
        public let allowNull: Bool?
    }

    public struct PreferenceSchema: Codable {
        public let type: String?
        public let format: String?
        public let required: Bool?
        public let writeAccess: String?
        public let currentDocVersion: Double?
        public let minDocVersion: Double?
    }

    public struct SubscriptionSchema: Codable {
        public let type: String?
        public let description: String?
        public let required: Bool?
        public let doubleOptIn: Bool?
    }

    public struct ProfileSchema: Codable {
        public let type: String?
        public let writeAccess: String?
        public let format: String?
        public let encrypt: String?
        public let required: Bool?
        public let allowNull: Bool?

    }
}

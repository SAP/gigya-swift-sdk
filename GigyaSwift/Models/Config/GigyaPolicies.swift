//
//  GigyaPolicies.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 22/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation

public struct GigyaPolicies: Codable {
    public var registration: Registration?

    public var GigyaPlugins: GigyaPlugins?

    public var accountOptions: AccountOptions?

    public var passwordComplexity: PasswordComplexity?

    public var security: Security?

    public var emailVerification: EmailVerification?

    public var authentication: Authentication?

    public var emailNotifications: EmailNotifications?

    public var preferencesCenter: PreferencesCenter?

    public var doubleOptIn: DoubleOptIn?

    public var passwordReset: PasswordReset?

    public var CodeVerification: CodeVerification?

    public var profilePhoto: ProfilePhoto?

    public var twoFactorAuth: TwoFactorAuth?

    public var federation: Federation?

    public var LiteAccountEnabled: Bool?


    public struct Registration: Codable {
        public var requireCaptcha: Bool?

        public var requireSecurityQuestion: Bool?

        public var requireLoginID: Bool?

        public var enforceCoppa: Bool?
    }

    public struct GigyaPlugins: Codable {
        public var noLoginBehavior: ConnectWithoutLoginBehavior?

        public var defaultRegScreenSet: String?

        public var defaultMobileRegScreenSet: String?

        public var sessionExpiration: Int?

        public var rememberSessionExpiration: Int?

        public enum ConnectWithoutLoginBehavior: String, Codable {
            case tempUser
            case alwaysLogin
            case loginExistingUser
        }
    }

    public struct AccountOptions: Codable {
        public var verifyEmail: Bool?

        public var verifyProviderEmail: Bool?

        public var useCodeVerification: Bool?

        public var allowUnverifiedLogin: Bool?

        public var preventLoginIDHarvesting: Bool?

        public var sendWelcomeEmail: Bool?

        public var sendAccountDeletedEmail: Bool?

        public var defaultLanguage: Bool?

        public var loginIdentifiers: LoginIdentifierConflict?

        public var loginIdentifierConflict: String?

        public enum LoginIdentifierConflict: String, Codable {
            case failOnSiteConflictingIdentity
            case ignore
            case failOnAnyConflictingIdentity
        }
    }

    public struct PasswordComplexity: Codable {
        public var minCharGroups: Int? // minimum number of character groups required

        public var MinLength: Int?

        public var regExp: String? // optionally a custom regExp to validate the password complexity
    }

    public struct Security: Codable {
        public var accountLockout: AccountLockout?

        public var captcha: Captcha?

        public var ipLockout: IpLockout?

        public var passwordChangeInterval: Int?

        public var passwordHistorySize: Int?
        public var riskAssessmentWithReCaptchaV3: Bool?

        public struct AccountLockout: Codable {
            public var failedLoginThreshold: Int?
            public var lockoutTimeSec: Int?
            public var failedLoginResetSec: Int?
        }

        public struct Captcha: Codable {
            public var failedLoginThreshold: Int
        }

        public struct IpLockout: Codable {
            public var hourlyFailedLoginThreshold: Int?
            public var lockoutTimeSec: Int?
        }
    }


    public struct EmailVerification: Codable {
        public var defaultLanguage: String?

        public var emailTemplates: [String: String]?

        // Next URL to go to after verifying the email by clicking on it.
        public var NextURL: String?

        // How long the verification email is valid, in seconds.
        public var verificationEmailExpiration: Int?

        public var autoLogin: Bool?

        public var nextURLMapping: [NextURLMapping]?

        public struct NextURLMapping: Codable {
            public var regSource: String?
            public var nextURL: String?
        }
    }

    public struct Authentication: Codable {
        public var methods: [AuthMethodType: AuthMethod]?

        public enum AuthMethodType: String, Codable {
            case password
            case push
        }

        public struct AuthMethod: Codable {
            public var enabled: Bool?
            public var params: [String: String]? // NOTE: what is @parms?
        }
    }

    public struct EmailNotifications: Codable {
        public var welcomeEmailTemplates: [String: String]?

        public var welcomeEmailDefaultLanguage: String?

        public var accountDeletedEmailTemplates: [String: String]?

        public var accountDeletedEmailDefaultLanguage: String?

        public var confirmationEmailTemplates: [String: String]?

        public var confirmationEmailDefaultLanguage: String?

    }

    public struct PreferencesCenter: Codable {
        public var defaultLanguage: String?

        public var emailTemplates: [String: String]?

        public var redirectURL: String?

        public var linkPlaceHolder: String?

    }

    public struct DoubleOptIn: Codable {
        public var defaultLanguage: String?

        public var confirmationEmailTemplates: [String: String]?

        public var nextURL: String?

        public var confirmationLinkExpiration: Double?
    }

    public struct PasswordReset: Codable {
        public var defaultLanguage: String?

        public var emailTemplates: [String: String]?

        public var requireSecurityCheck: Bool?

        public var resetURL: String?

        public var tokenExpiration: Int?

        public var sendConfirmationEmail: Bool?

    }

    public struct CodeVerification: Codable {
        public var defaultLanguage: String?

        public var codePlaceHolder: String?

        public var emailTemplates: [String: String]?
    }

    public struct ProfilePhoto: Codable {
        public var thumbnailWidth: Int?

        public var thumbnailHeight: Int?
    }

    public struct TwoFactorAuth: Codable {
        public var providers: [Provider]?
        public var emailProvider: EmailTemplate?
        public var smsProvider: SMSProvider?

        public struct EmailTemplate: Codable {
            public var defaultLanguage: String?

            public var emailTemplates: [String: String]?
        }

        public struct SMSProvider: Codable {
            public var message: String?
        }

        public struct Provider: Codable {
            public var name: String?
            public var enabled: Bool?
            public var params: [String: String]?
        }
    }

    public struct Federation: Codable {
        public var allowMultipleIdentities: Bool?
    }
}

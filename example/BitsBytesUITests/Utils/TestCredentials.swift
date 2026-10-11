import Foundation

struct TestCredentials {
    static let email = "bitsbytes+test@example.com"   // replace with real CDC test account on site 4_S8VHbHlOBdJrX8CRYjIbdw
    static let password = "Test1234!"
    static let firstName = "Test"
    static let lastName = "User"
    static let phone = "+1-555-000-0000"              // replace with SMS-capable test number

    // Domain used for registration tests — must be allowed by the CDC site's email policy.
    // mailinator.com is typically blocked; use gmail.com or your company domain.
    static let registrationDomain = "gmail.com"

    struct Google {
        static let email = "bitsbytes.google.test@gmail.com"  // replace with real account
        static let password = "GoogleTest1234!"
    }
}

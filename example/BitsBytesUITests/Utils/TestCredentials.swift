import Foundation

struct TestCredentials {
    static let password = "Test1234!"
    static let firstName = "Test"
    static let lastName = "User"
    static let phone = "+1-555-000-0000"

    // Email is generated fresh each run by RegistrationTests and written to a temp file.
    // All subsequent tests read it from there so they use the same account.
    static var email: String {
        get {
            (try? String(contentsOf: emailFile, encoding: .utf8)) ?? ""
        }
        set {
            try? newValue.write(to: emailFile, atomically: true, encoding: .utf8)
        }
    }

    private static var emailFile: URL {
        URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("bitsbytes_test_email.txt")
    }

    struct Google {
        static let email = "bitsbytes.google.test@gmail.com"
        static let password = "GoogleTest1234!"
    }
}

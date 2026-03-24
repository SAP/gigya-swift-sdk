import UIKit
import AuthenticationServices

final class ViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    private var authSession: ASWebAuthenticationSession?

    @IBAction func buttonTapped(_ sender: UIButton) {
        guard authSession == nil else { return }
        startWebAuth()
    }

    @MainActor
    private func startWebAuth() {
        let url = URL(string: "https://y-id-stg.p81webmarketing.com")!


        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: nil) { [weak self] callbackURL, error in
            defer { self?.authSession = nil }

            if let error = error as? ASWebAuthenticationSessionError {
                switch error.code {
                case .canceledLogin:
                    print("ASWebAuth: user canceled")
                default:
                    print("ASWebAuth error(\(error.code.rawValue)): \(error.localizedDescription)")
                }
                return
            }

            print("ASWebAuth finished. callbackURL: \(String(describing: callbackURL))")
        }

        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true

        self.authSession = session

        let started = session.start()
        print("ASWebAuthenticationSession.start() -> \(started)")
        if !started {
            self.authSession = nil
            assertionFailure("Failed to start ASWebAuthenticationSession")
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let w = view.window { return w }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene,
                  scene.activationState == .foregroundActive else { continue }
            if let key = windowScene.windows.first(where: { $0.isKeyWindow }) { return key }
        }
        assertionFailure("No valid anchor window; ensure call after viewDidAppear & sceneDidBecomeActive")
        return ASPresentationAnchor()
    }
}

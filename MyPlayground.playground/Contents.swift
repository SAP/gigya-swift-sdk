import GigyaSwift

let errosCodes = Interruption.allCases

if let interruption = Interruption(rawValue: 206002), errosCodes.contains(interruption) {
    print(true)
} else {
    print(false)

}

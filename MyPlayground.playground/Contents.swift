//import GigyaSwift
//
//func dos() {
//    if let path = Bundle.main.path(forResource: "CountryCode", ofType: "json") {
//        do {
//            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//            if let jsonResult = jsonResult as? [Any] {
//                // do stuff
//                print("kaka")
//            }
//        } catch {
//            // handle error
//        }
//    }
//}
//
//dos()

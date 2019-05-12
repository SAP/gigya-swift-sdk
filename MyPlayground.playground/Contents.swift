
let oldAccount = ["test": "yes", "none": "true"]
let newAccount = ["test": "no", "none": "true"]

let diff = newAccount.filter { $0.value as? String != oldAccount[$0.key] as? String }

print(diff)


//
//  AboutMeViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 17/04/2024.
//

import Foundation
import Gigya

final class AboutMeViewModel: BaseViewModel {
    @Published var lastName: String = ""
    @Published var firstName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var birthDay: Date = Date.init(timeIntervalSince1970: 0) {
        didSet {
            self.birthDatyIsUpdated = true
        }
    }
    @Published var country: String = ""

    @Published var error: String = ""
    
    var birthDatyIsUpdated: Bool = false
    
        
    var account: AccountModel?

    override init(gigya: GigyaService) {
        super.init(gigya: gigya)
        
        getAccount()
    }
    
    func getAccount() {
        gigya?.shared.getAccount(){ result in
            switch result {
            case .success(data: let data):
                self.lastName = data.profile?.lastName ?? ""
                self.firstName = data.profile?.firstName ?? ""
                self.email = data.profile?.email ?? ""
                self.phone = data.phoneNumber ?? ""
                self.country = data.profile?.country ?? ""
                self.account = data
                
                if let birthDay = data.profile?.birthDay,
                    let birthMonth = data.profile?.birthMonth,
                    let birthYear = data.profile?.birthYear {
                    var dateComponents = DateComponents()
                    dateComponents.year = birthYear
                    dateComponents.month = birthMonth
                    dateComponents.day = birthDay
                    
                    self.birthDay = Calendar.current.date(from: dateComponents)!
                }
            case .failure(_):
                break
            }
        }
    }
    
    func setAccount() {
        guard var account = account else { return }
        
        if birthDatyIsUpdated {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: birthDay)
            let month = calendar.component(.month, from: birthDay)
            let day = calendar.component(.day, from: birthDay)
            
            account.profile?.birthDay = day
            account.profile?.birthMonth = month
            account.profile?.birthYear = year
        }

        account.profile?.firstName = firstName
        account.profile?.lastName = lastName
        account.profile?.country = country
        
        toggelLoader()
        
        gigya?.shared.setAccount(with: account) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(data: let data):
                self.toggelLoader()
                self.account = data
            case .failure(let error):
                switch error {
                case .gigyaError(data: let data):
                    self.error = data.errorMessage ?? error.localizedDescription
                default:
                    self.error = error.localizedDescription
                }
                self.toggelLoader()
            }
        }
    }

}

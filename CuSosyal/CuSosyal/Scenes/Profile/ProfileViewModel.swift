//
//  ProfileViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 16/4/26.
//

import Foundation

protocol ProfileViewModelInterface {
    func logout()
    func viewDidLoad()
}

class ProfileViewModel {
    
    private let authManager: any AuthManagerInterface
    
    init(authManager: any AuthManagerInterface = AuthManager.shared) {
        self.authManager = authManager
    }
    
}

extension ProfileViewModel: ProfileViewModelInterface {
    
    func logout() {
        do {
            try authManager.signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func viewDidLoad() {
        
    }
    
}

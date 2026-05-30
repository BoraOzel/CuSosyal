//
//  LoginViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 15/3/26.
//

import Foundation

protocol LoginViewModelInterface {
    func login(email: String?, password: String?) async throws
}

class LoginViewModel {
    
    private let authManager: AuthManagerInterface
    
    init(authManager: AuthManagerInterface = AuthManager.shared) {
        self.authManager = authManager
    }

}

extension LoginViewModel: LoginViewModelInterface {
    @MainActor
    func login(email: String?, password: String?) async throws {
        
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            throw AuthError.blank
        }
        
        if !email.contains("@") {
            throw AuthError.invalidEmail
        }
        
        try await authManager.signIn(with: email, password: password)
        
    }
    
}

//
//  ResetPasswordViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 21/5/26.
//

import Foundation

protocol ResetPasswordViewModelInterface {
    func resetPassword(current: String, new: String, verify: String) async throws
}

class ResetPasswordViewModel {
    
    private let authManager: AuthManagerInterface
    
    init(authManager: AuthManagerInterface = AuthManager.shared) {
        self.authManager = authManager
    }
    
}

extension ResetPasswordViewModel: ResetPasswordViewModelInterface {
    
    func resetPassword(current: String, new: String, verify: String) async throws {
        guard !current.isEmpty, !new.isEmpty, !verify.isEmpty else {
            throw AuthError.blank
        }
        
        guard new == verify else {
            throw AuthError.passwordsDontMatch
        }
        
        guard new.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        try await authManager.resetPassword(currentPassword: current, newPassword: new)
    }
    
}

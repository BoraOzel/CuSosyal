//
//  RegisterViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 24/3/26.
//

import Foundation

protocol RegisterViewModelInterface: AnyObject {
    func register(name: String, email: String, password: String, tags: [Tags]) async throws
}

class RegisterViewModel {
    
    private let authManager = AuthManager.shared
    weak var view: RegisterViewControllerInterface?
    
}

extension RegisterViewModel: RegisterViewModelInterface {
    @MainActor
    func register(name: String, email: String, password: String, tags: [Tags]) async throws {
        try await authManager.registerUser(with: email,
                                           password: password,
                                           name: name,
                                           interestedTags: tags)
    }
}

//
//  ProfileViewModel.swift
//  CuSosyal
//
//  Created by Bora Özel on 16/4/26.
//

import Foundation

protocol ProfileViewModelInterface {
    var userName: String { get }
    var userSurname: String { get }
    var userEmail: String { get }
    var userTags: [Tags] { get }
    
    func logout()
    func fetchProfile() async
    func updateProfile(name: String, surname: String, email: String, currentPassword: String?) async throws
    func deleteProfile(password: String) async throws
}

class ProfileViewModel {
    
    private let authManager: any AuthManagerInterface
    private let networkManager: any NetworkManagerInterface
    
    private(set) var userName: String = ""
    private(set) var userSurname: String = ""
    private(set) var userEmail: String = ""
    private(set) var userTags: [Tags] = []
    
    init(authManager: any AuthManagerInterface = AuthManager.shared,
         networkManager: any NetworkManagerInterface = NetworkManager.shared) {
        self.authManager = authManager
        self.networkManager = networkManager
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
    
    func fetchProfile() async {
        do {
            let user = try await networkManager.fetchCurrentUser()
            await MainActor.run {
                self.userName = user.name
                self.userSurname = user.surname
                self.userEmail = user.email
                self.userTags = user.interestedTags ?? []
            }
        }
        catch {
            print("fetchProfile failed: \(error.localizedDescription)")
        }
    }
    
    func updateProfile(name: String, surname: String, email: String, currentPassword: String? = nil) async throws {
        try await networkManager.updateUserProfile(name: name, surname: surname, email: email)

            if email != userEmail, let password = currentPassword {
                try await authManager.updateEmail(to: email, currentPassword: password)
            }
        await MainActor.run {
            self.userName = name
            self.userSurname = surname
            self.userEmail = email
        }
    }
    
    func deleteProfile(password: String) async throws {
        try await networkManager.deleteUserData()
        try await authManager.deleteAccount(currentPassword: password)
    }
    
}

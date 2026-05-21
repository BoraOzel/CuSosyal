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
    
}

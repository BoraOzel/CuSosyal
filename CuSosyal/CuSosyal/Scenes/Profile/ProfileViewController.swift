//
//  ProfileViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 16/4/26.
//

import UIKit

class ProfileViewController: UIViewController,
                             AlertPresentable {
    
    private let viewModel: ProfileViewModelInterface
    private let authManager = AuthManager.shared
    
    init(viewModel: ProfileViewModelInterface = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "ProfileViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        viewModel.logout()
        guard let window = self.view.window else { return }
        Router.switchToAuth(window: window)
    }
    
}

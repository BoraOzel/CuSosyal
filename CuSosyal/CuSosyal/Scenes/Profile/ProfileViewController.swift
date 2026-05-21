//
//  ProfileViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 16/4/26.
//

import UIKit

protocol ProfileViewControllerInterface {
    func fetchProfile()
    func setupTextFields()
}

class ProfileViewController: UIViewController,
                             AlertPresentable {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private let viewModel: ProfileViewModelInterface
    
    init(viewModel: ProfileViewModelInterface = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "ProfileViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfile()
    }
    
    @IBAction func interestButtonClicked(_ sender: Any) {
        let tagsVC = TagsViewController()
        tagsVC.selectedTags = viewModel.userTags
        navigationController?.pushViewController(tagsVC, animated: true)
    }
    
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        viewModel.logout()
        guard let window = self.view.window else { return }
        Router.switchToAuth(window: window)
    }
    
}

extension ProfileViewController: ProfileViewControllerInterface {
    
    func fetchProfile() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.fetchProfile()
            await MainActor.run { self.setupTextFields() }
        }
    }
    
    func setupTextFields() {
        nameTextField.text = viewModel.userName
        surnameTextField.text = viewModel.userSurname
        emailTextField.text = viewModel.userEmail
        
        nameTextField.isUserInteractionEnabled = false
        surnameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
    }
    
}

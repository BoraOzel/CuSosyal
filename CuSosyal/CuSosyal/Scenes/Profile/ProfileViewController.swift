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
    func setEditMode(_ enabled: Bool)
    func setupNavigationBar()
    func presentPasswordAlert()
    func performDeleteAccount(password: String)
    func performUpdate(name: String, surname: String, email: String, currentPassword: String?, emailChanged: Bool)
}

class ProfileViewController: UIViewController,
                             AlertPresentable {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private let viewModel: ProfileViewModelInterface
    
    private var isEditMode = false
    
    init(viewModel: ProfileViewModelInterface = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "ProfileViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        hideKeyboardWhenTappedAround()
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
    
    @IBAction func resetPasswordClicked(_ sender: Any) {
        let resetVC = ResetPasswordViewController()
        navigationController?.pushViewController(resetVC, animated: true)
    }
    
    @IBAction func deleteAccountButtonClicked(_ sender: Any) {
        showConfirmationAlert(
            title: "Hesabı Sil",
            message: "Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
            confirmText: "Devam Et",
            cancelText: "İptal"
        ) { [weak self] action in
            guard let self, action == .ok else { return }
            self.presentPasswordAlert()
        }
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        viewModel.logout()
        guard let window = self.view.window else { return }
        Router.switchToAuth(window: window)
    }
    
    @objc func editSaveTapped() {
        guard isEditMode else { setEditMode(true); return }
        
        guard let name    = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let surname = surnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let email   = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty, !surname.isEmpty, !email.isEmpty else {
            showAlert(title: "Hata", message: "Alanlar boş bırakılamaz.", buttonText: "Tamam")
            return
        }
        
        let emailChanged = email != viewModel.userEmail
        
        if emailChanged {
            showTextInputAlert(
                title: "Şifrenizi Girin",
                message: "Email adresinizi güncellemek için mevcut şifrenizi girin.",
                placeholder: "Şifre",
                isSecure: true,
                confirmText: "Kaydet",
                confirmStyle: .default,
                cancelText: "İptal"
            ) { [weak self] password in
                guard let self, let password, !password.isEmpty else { return }
                self.performUpdate(name: name, surname: surname, email: email, currentPassword: password, emailChanged: true)
            }
        } else {
            performUpdate(name: name, surname: surname, email: email, currentPassword: nil, emailChanged: false)
        }
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
    
    func setEditMode(_ enabled: Bool) {
        isEditMode = enabled
        
        nameTextField.isUserInteractionEnabled = enabled
        surnameTextField.isUserInteractionEnabled = enabled
        emailTextField.isUserInteractionEnabled = enabled
        
        navigationItem.rightBarButtonItem?.title = enabled ? "Kaydet" : "Düzenle"
        
        if enabled {
            nameTextField.becomeFirstResponder()
        }
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Düzenle",
            style: .plain,
            target: self,
            action: #selector(editSaveTapped)
        )
    }
    
    func presentPasswordAlert() {
        showTextInputAlert(
            title: "Şifrenizi Girin",
            message: "Hesabınızı silmek için mevcut şifrenizi girin.",
            placeholder: "Şifre",
            isSecure: true,
            confirmText: "Hesabı Sil",
            confirmStyle: .destructive,
            cancelText: "İptal"
        ) { [weak self] password in
            guard let self, let password, !password.isEmpty else { return }
            self.performDeleteAccount(password: password)
        }
    }
    
    func performDeleteAccount(password: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.deleteProfile(password: password)
                await MainActor.run {
                    guard let window = self.view.window else { return }
                    Router.switchToAuth(window: window)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Hata",
                                   message: error.localizedDescription,
                                   buttonText: "Tamam")
                }
            }
        }
    }
    
    func performUpdate(name: String, surname: String, email: String, currentPassword: String?, emailChanged: Bool) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.updateProfile(name: name, surname: surname, email: email, currentPassword: currentPassword)
                await MainActor.run {
                    self.setEditMode(false)
                    if emailChanged {
                        self.showAlert(
                            title: "Doğrulama Gönderildi",
                            message: "Yeni email adresinize bir doğrulama linki gönderildi. Linke tıkladıktan sonra email adresiniz güncellenecektir.",
                            buttonText: "Tamam"
                        )
                    }
                    else {
                        self.showAlert(
                            title: "Başarılı",
                            message: "Bilgileriniz güncellendi.",
                            buttonText: "Tamam"
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Hata", message: error.localizedDescription, buttonText: "Tamam")
                }
            }
        }
    }
    
}


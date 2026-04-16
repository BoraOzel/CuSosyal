//
//  RegisterViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 16/3/26.
//

import UIKit

protocol RegisterViewControllerInterface: AnyObject {
    func navigateToTags(vc: UIViewController)
    func navigateToApp()
}

class RegisterViewController: UIViewController,
                              AlertPresentable {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVerifyTextField: UITextField!
    
    private var viewModel: RegisterViewModelInterface
    
    init(viewModel: RegisterViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "RegisterViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let passwordVerify = passwordVerifyTextField.text, !passwordVerify.isEmpty else {
            showAlert(title: "Hata",
                      message: "Lütfen tüm alanları doldurunuz.",
                      buttonText: "Tamam")
            
            return
        }
        
        if password != passwordVerify {
            showAlert(title: "Hata",
                      message: "Girdiğiniz parolalar eşleşmiyor.",
                      buttonText: "Tamam")
            
            return
        }
        
        if !email.contains("@") {
            showAlert(title: "Hata",
                      message: "Geçerli bir email formatı giriniz.",
                      buttonText: "Tamam")
            
            return
        }
        
        let tagsVC = TagsViewController()
        tagsVC.delegate = self
        
        navigateToTags(vc: tagsVC)
    }
    
    
}

extension RegisterViewController: RegisterViewControllerInterface {
    func navigateToTags(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            
            return
        }
        Router.switchToApp(window: window)
    }
}

extension RegisterViewController: TagSelectionDelegate {
    func didSelectTags(tags: [Tags]) {
        Task {
            do {
                try await viewModel.register(name: nameTextField.text!,
                                             email: emailTextField.text!,
                                             password: passwordTextField.text!,
                                             tags: tags)
                await MainActor.run {
                    self.navigateToApp()
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
}

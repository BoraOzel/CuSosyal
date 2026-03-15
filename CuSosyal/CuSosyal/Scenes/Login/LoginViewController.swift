//
//  LoginViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 11/3/26.
//

import UIKit

protocol LoginViewControllerInterface {
    func navigateToApp()
    func navigateToRegister(vc: UIViewController)
}

class LoginViewController: UIViewController,
                           AlertPresentable {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var viewModel: LoginViewModelInterface
    
    init(viewModel: LoginViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "LoginViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
                
        Task{
            do {
                try await viewModel.login(email: emailTextField.text, password: passwordTextField.text)
                navigateToApp()
            }
            catch {
                if let authError = error as? AuthError {
                    showAlert(title: "Hata",
                              message: authError.localizedDescription,
                              buttonText: "Tamam")
                }
            }
        }
        
    }
    
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        
    }
    
}

extension LoginViewController: LoginViewControllerInterface {
    
    func navigateToApp() {
        guard let window = self.view.window else { return }
        Router.switchToApp(window: window)
    }
    
    func navigateToRegister(vc: UIViewController) {

    }
    
}

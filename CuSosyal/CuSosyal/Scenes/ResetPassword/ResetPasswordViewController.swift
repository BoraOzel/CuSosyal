//
//  ResetPasswordViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 21/5/26.
//

import UIKit

protocol ResetPasswordViewControllerInterface {
    func resetPassword()
}

class ResetPasswordViewController: UIViewController, AlertPresentable {
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    
    private let viewModel: ResetPasswordViewModelInterface
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    init(viewModel: ResetPasswordViewModelInterface = ResetPasswordViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "ResetPasswordViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction func resetPasswordButtonClicked(_ sender: Any) {
        resetPassword()
    }
    
}

extension ResetPasswordViewController: ResetPasswordViewControllerInterface {
    
    func resetPassword() {
        let current = currentPasswordTextField.text ?? ""
        let new = newPasswordTextField.text ?? ""
        let verify = verifyPasswordTextField.text ?? ""
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.resetPassword(current: current, new: new, verify: verify)
                await MainActor.run {
                    self.showAlert(title: "Başarılı",
                              message: "Şifreniz başarıyla güncellendi.",
                                   buttonText: "Tamam") {_ in 
                        self.navigationController?.popViewController(animated: true)
                    }
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



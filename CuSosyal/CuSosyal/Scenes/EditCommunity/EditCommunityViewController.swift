//
//  EditCommunityViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 25/5/26.
//

import UIKit
import SDWebImage
import PhotosUI

protocol EditCommunityViewControllerInterface {
    func configureUI()
    func setupNavigationBar()
    func presentImagePicker()
    func setupUI()
}

class EditCommunityViewController: UIViewController, AlertPresentable {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    private let viewModel: EditCommunityViewModelInterface
    private var selectedImage: UIImage?
    
    init(viewModel: EditCommunityViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "EditCommunityViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupNavigationBar()
        setupUI()
    }
    
    @IBAction func changeButtonClicked(_ sender: Any) {
        presentImagePicker()
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else {
            showAlert(title: "Hata",
                      message: "İsim ve açıklama boş bırakılamaz.",
                      buttonText: "Tamam")
            return
        }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.5)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.save(name: name,
                                         description: description,
                                         imageData: imageData)
                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch {
                await MainActor.run {
                    self.showAlert(title: "Hata",
                                   message: error.localizedDescription,
                                   buttonText: "Tamam")
                }
            }
        }
    }
    
    @objc func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension EditCommunityViewController: EditCommunityViewControllerInterface {
    
    func configureUI() {
        nameTextField.text = viewModel.community.name
        descriptionTextView.text = viewModel.community.description
        logoImageView.sd_setImage(with: URL(string: viewModel.community.logoUrl ?? ""))
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "İptal",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    
    
    func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func setupUI() {
        descriptionTextView.delegate = self
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.separator.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.font = nameTextField.font
        hideKeyboardWhenTappedAround()
    }
    
}

extension EditCommunityViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self,
                  let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                let estimatedSize = image.jpegData(compressionQuality: 1.0)?.count ?? 0
                let maxBytes = 1 * 1024 * 1024
                
                if estimatedSize > maxBytes {
                    self.showAlert(title: "Dosya Çok Büyük",
                                   message: "Lütfen 1MB'dan küçük bir görsel seçiniz.",
                                   buttonText: "Tamam")
                    return
                }
                
                self.selectedImage = image
                self.logoImageView.image = image
            }
        }
    }
}

extension EditCommunityViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 750
    }
    
}


//
//  EditEventViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 25/5/26.
//

import UIKit

protocol EditEventViewControllerInterface {
    func configureForMode()
    func setupNavigationBar()
    func setupDescriptionTextView()
}

class EditEventViewController: UIViewController, AlertPresentable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    private let viewModel: EditEventViewModelInterface
    
    init(viewModel: EditEventViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "EditEventViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureForMode()
        setupNavigationBar()
        setupDescriptionTextView()
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let title = eventTitleTextField.text, !title.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty,
              let location = locationTextField.text, !location.isEmpty else {
            showAlert(title: "Hata", message: "Lütfen tüm alanları doldurunuz.", buttonText: "Tamam")
            return
        }
        Task {
            [weak self] in
            guard let self else { return }
            do {
                try await viewModel.save(title: title, location: location, date: eventDatePicker.date, description: description)
                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch {
                showAlert(title: "Hata", message: error.localizedDescription, buttonText: "Tamam")
            }
        }
    }
    
    @objc func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension EditEventViewController: EditEventViewControllerInterface {
    
    func configureForMode() {
        if viewModel.isEditMode {
            titleLabel.text = "Etkinliği Düzenle"
        }
        
        if let event = viewModel.existingEvent {
            eventTitleTextField.text  = event.title
            locationTextField.text    = event.location
            descriptionTextView.text = event.description
            eventDatePicker.date      = event.date
        }
        else {
            titleLabel.text = "Etkinlik Ekle"
        }
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "İptal",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    func setupDescriptionTextView() {
        descriptionTextView.delegate = self
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.separator.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.font = eventTitleTextField.font
    }
    
}

extension EditEventViewController: UITextViewDelegate {
    
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


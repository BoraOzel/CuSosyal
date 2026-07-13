//
//  EventDetailViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 23/4/26.
//

import UIKit
import SDWebImage

protocol EventDetailViewControllerInterface {
    func configureUI()
    func fetchRegistrationStatus()
    func updateButtonState()
    func askAddToCalendar()
    func addToCalendar()
    func setupAdminNavigationBar()
}

class EventDetailViewController: UIViewController, AlertPresentable {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    private let viewModel: EventDetailViewModelInterface
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
    
    init(viewModel: EventDetailViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "EventDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRegistrationStatus()
        setupAdminNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { [weak self] in
            guard let self else { return }
            await viewModel.refreshEvent()
            await MainActor.run { self.configureUI() }
        }
    }
    
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.toggleRegistration()
                await MainActor.run {
                    self.updateButtonState()
                    self.configureUI()
                    if self.viewModel.isRegistered {
                        self.askAddToCalendar()
                    }
                }
            }
            catch {
                await MainActor.run {
                    self.showAlert(title: "Hata", message: error.localizedDescription, buttonText: "Tamam")
                    self.updateButtonState()
                }
            }
        }
    }
    
    
    @objc private func editButtonTapped() {
        let editVM = EditEventViewModel(mode: .edit(event: viewModel.event))
        let editVC = EditEventViewController(viewModel: editVM)
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        showConfirmationAlert(
            title: "Etkinliği Sil",
            message: "Bu etkinliği silmek istediğinize emin misiniz?"
        ) { [weak self] action in
            guard let self, action == .ok  else { return }
            Task {
                do {
                    try await self.viewModel.deleteEvent()
                    await MainActor.run {
                        self.navigationController?.popViewController(animated: true)
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
    
}

extension EventDetailViewController: EventDetailViewControllerInterface {
    
    func configureUI() {
        let event = viewModel.event
        nameLabel.text = event.title
        locationLabel.text = "📍\(event.location)"
        descriptionLabel.text = event.description
        dateLabel.text = "🗓️\(Self.dateFormatter.string(from: event.date))"
        capacityLabel.text = viewModel.capacityText
        imageView.sd_setImage(with: URL(string: viewModel.logoUrl ?? ""))
    }
    
    func fetchRegistrationStatus() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.fetchRegistrationStatus()
            await MainActor.run { self.updateButtonState() }
        }
    }
    
    func updateButtonState() {
        let isRegistered = viewModel.isRegistered
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        
        if !isRegistered && viewModel.event.isFull {
            config.title = "KONTENJAN DOLU"
            config.baseBackgroundColor = .systemGray
            registerButton.isEnabled = false
        } else {
            config.title = isRegistered ? "KAYDIMI İPTAL ET" : "KAYIT OL"
            config.baseBackgroundColor = isRegistered ? .systemRed : UIColor(named: "primaryColor")
            registerButton.isEnabled = true
        }
        registerButton.configuration = config
    }
    
    func askAddToCalendar() {
        showConfirmationAlert(title: "Takvime Ekle",
                              message:"Bu etkinliği takvime eklemek ister misiniz?") { [weak self] action in
            if action == .ok {
                self?.addToCalendar()
            }
        }
    }
    
    func addToCalendar() {
        Task { [weak self] in
            guard let self else { return}
            do {
                try await viewModel.addToCalendar()
                await MainActor.run {
                    self.showAlert(title: "Başarılı",
                                   message: "Etkinlik takviminize eklendi.",
                                   buttonText: "Tamam")
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
    
    func setupAdminNavigationBar() {
        guard viewModel.isCurrentUserAdmin else { return }
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(editButtonTapped))
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(deleteButtonTapped))
        deleteButton.tintColor = .red
        navigationItem.rightBarButtonItems = [editButton, deleteButton]
    }
    
}




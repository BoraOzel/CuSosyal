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
}

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
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
        configureUI()
        fetchRegistrationStatus()
    }
    
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.toggleRegistration()
            await MainActor.run { self.updateButtonState() }
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
        config.title = isRegistered ? "KAYDIMI İPTAL ET" : "KAYIT OL"
        config.baseBackgroundColor = isRegistered ? .systemRed : UIColor(named: "primaryColor")
        registerButton.configuration = config
    }
    
}



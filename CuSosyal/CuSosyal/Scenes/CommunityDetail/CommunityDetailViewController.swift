//
//  CommunityDetailViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 19/4/26.
//

import UIKit
import SDWebImage

protocol CommunityDetailViewControllerInterface {
    func configureUI()
    func setupCollectionView()
    func fetchEvents()
    func updateEventsUI()
}

class CommunityDetailViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var emptyEventLabel: UILabel!
    
    private let viewModel: CommunityDetailViewModelInterface
    
    init(viewModel: CommunityDetailViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "CommunityDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureUI()
        fetchEvents()
    }
    
}

extension CommunityDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = viewModel.getEvent(at: indexPath.item) else { return }
        
        let detailViewModel = EventDetailViewModel(
            event: event,
            logoUrl: viewModel.community.logoUrl
        )
        let detailVC = EventDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension CommunityDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfEvents()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as? EventCollectionViewCell,
            let event = viewModel.getEvent(at: indexPath.item)
        else { return UICollectionViewCell() }
        
        cell.configure(with: event, logoUrl: viewModel.community.logoUrl ?? "")
        return cell
    }
    
}

extension CommunityDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)     }
}



extension CommunityDetailViewController: CommunityDetailViewControllerInterface {
    
    func configureUI() {
        nameLabel.text = viewModel.community.name
        descriptionLabel.text = viewModel.communityDescription
        imageView.sd_setImage(with: URL(string: viewModel.community.logoUrl ?? ""))
    }
    
    func setupCollectionView() {
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.register(UINib(nibName: "EventCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EventCollectionViewCell")
        eventsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func fetchEvents() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.getEvents()
            await MainActor.run { self.updateEventsUI() }
        }
    }
    
    func updateEventsUI() {
        let isEmpty = viewModel.numberOfEvents() == 0
        eventsCollectionView.isHidden = isEmpty
        emptyEventLabel.isHidden = !isEmpty
        
        if !isEmpty {
            eventsCollectionView.reloadData()
        }
    }
    
}

//
//  HomeViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 3/3/26.
//

import UIKit

protocol HomeViewControllerInterface {
    func fetchHomeData()
    func setupInterestCollectionView()
    func setupSavedEventsCollectionView()
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var savedEventsCollectionView: UICollectionView!
    @IBOutlet weak var interestCollectionView: UICollectionView!
    @IBOutlet weak var askAiView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private let viewModel: HomeViewModelInterface
    
    init(viewModel: HomeViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: "HomeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterestCollectionView()
        setupSavedEventsCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchHomeData()
    }
    
    
    @IBAction func profileButtonClicked(_ sender: Any) {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }
    
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == interestCollectionView {
            return viewModel.numberOfSuggestedCommunities()
        }
        else {
            return viewModel.numberOfSavedEvents()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == interestCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedCollectionViewCell",
                                                                for: indexPath) as? SuggestedCollectionViewCell,
                  let community = viewModel.getSuggestedCommunity(at: indexPath.item) else { return UICollectionViewCell() }
            
            cell.configure(data: community)
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell",
                                                                for: indexPath) as? EventCollectionViewCell,
                  let event = viewModel.getSavedEvent(at: indexPath.item)
            else { return UICollectionViewCell() }
            
            let logoUrl = viewModel.getCommunity(for: event)?.logoUrl ?? ""
            cell.configure(with: event, logoUrl: logoUrl)
            return cell
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == interestCollectionView {
            guard let community = viewModel.getSuggestedCommunity(at: indexPath.item) else { return }
            let detailViewModel = CommunityDetailViewModel(community: community)
            let detailViewController = CommunityDetailViewController(viewModel: detailViewModel)
            
            navigationController?.pushViewController(detailViewController, animated: true)
        }
        else {
            guard let event = viewModel.getSavedEvent(at: indexPath.item) else { return }
            let community = viewModel.getCommunity(for: event)
            let detailViewModel = EventDetailViewModel(event: event, logoUrl: community?.logoUrl)
            let detailVC = EventDetailViewController(viewModel: detailViewModel)
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == interestCollectionView {
            return CGSize(width: 160, height: 160)
        } else {
            return CGSize(width: 200, height: 200)
        }
    }
}

extension HomeViewController: HomeViewControllerInterface {
    
    func fetchHomeData() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.fetchHomeData()
            await MainActor.run {
                self.welcomeLabel.text = "Hoşgeldin, \(self.viewModel.userName) 👋🏻"
                self.interestCollectionView.reloadData()
                self.savedEventsCollectionView.reloadData()
            }
        }
    }
    
    func setupInterestCollectionView() {
        interestCollectionView.delegate = self
        interestCollectionView.dataSource = self
        interestCollectionView.register(UINib(nibName: "SuggestedCollectionViewCell", bundle: nil),
                                        forCellWithReuseIdentifier: "SuggestedCollectionViewCell")
        interestCollectionView.showsHorizontalScrollIndicator = false
        
        if let layout = interestCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    func setupSavedEventsCollectionView() {
        savedEventsCollectionView.delegate = self
        savedEventsCollectionView.dataSource = self
        savedEventsCollectionView.register(UINib(nibName: "EventCollectionViewCell", bundle: nil),
                                           forCellWithReuseIdentifier: "EventCollectionViewCell")
        savedEventsCollectionView.showsHorizontalScrollIndicator = false
        
        if let layout = savedEventsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
}

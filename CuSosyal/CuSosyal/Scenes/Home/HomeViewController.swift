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
        fetchHomeData()
    }
    
    
    @IBAction func profileButtonClicked(_ sender: Any) {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }
    
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfSuggestedCommunities()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedCollectionViewCell",
                                                            for: indexPath) as? SuggestedCollectionViewCell,
              let community = viewModel.getSuggestedCommunity(at: indexPath.item) else { return UICollectionViewCell() }
        
        cell.configure(data: community)
        return cell
    }
    
}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let community = viewModel.getSuggestedCommunity(at: indexPath.item) else { return }
        let detailViewModel = CommunityDetailViewModel(community: community)
        let detailViewController = CommunityDetailViewController(viewModel: detailViewModel)
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 160)
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
    
}

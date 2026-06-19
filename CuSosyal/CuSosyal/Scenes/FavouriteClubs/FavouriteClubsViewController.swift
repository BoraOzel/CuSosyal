//
//  FavouriteClubsViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 19/6/26.
//

import UIKit
import SDWebImage

protocol FavouriteClubsViewControllerInterface {
    func setupCollectionView()
    func setCustomFlowLayout()
    func fetchCommunities()
    func reloadData()
    func prefetchLogos(_ urls: [URL]) async
}

class FavouriteClubsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel: FavouriteClubsViewModelInterface
    
    init(viewModel: FavouriteClubsViewModelInterface = FavouriteClubsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "FavouriteClubsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setCustomFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCommunities()
    }
    
}

extension FavouriteClubsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let community = viewModel.getItem(at: indexPath.item) else { return }
        
        let detailViewModel = CommunityDetailViewModel(community: community)
        let detailVC = CommunityDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension FavouriteClubsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunitiesCollectionViewCell", for: indexPath) as! CommunitiesCollectionViewCell
        guard let item = viewModel.getItem(at: indexPath.item) else { return UICollectionViewCell() }
        
        cell.configure(data: item)
        
        return cell
    }
    
}

extension FavouriteClubsViewController: FavouriteClubsViewControllerInterface {
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "CommunitiesCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "CommunitiesCollectionViewCell")
    }
    
    func setCustomFlowLayout() {
        setCustomFlowLayout(lineSpacing: 10,
                            interItemSpacing: 10,
                            sectionInset: .zero,
                            estimatedItemSize: UICollectionViewFlowLayout.automaticSize)
    }
    
    func fetchCommunities() {
        showLoadingIndicator()
        Task { [weak self] in
            guard let self else { return }
            await viewModel.getFavouriteCommunities()
            await prefetchLogos(viewModel.logoURLs())
            reloadData()
            hideLoadingIndicator()
        }
    }
    
    @MainActor
    func reloadData() {
        collectionView.reloadData()
    }
    
    func prefetchLogos(_ urls: [URL]) async {
        guard !urls.isEmpty else { return }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withCheckedContinuation { continuation in
                    SDWebImagePrefetcher.shared.prefetchURLs(urls, progress: nil) { _, _ in
                        continuation.resume()
                    }
                }
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 6_000_000_000)
            }
            await group.next()
            group.cancelAll()
        }
    }

}

extension FavouriteClubsViewController: DynamicFlowLayoutCustomizable {
    typealias CustomLayout = SingleColumnDynamicHeightFlowLayout
}

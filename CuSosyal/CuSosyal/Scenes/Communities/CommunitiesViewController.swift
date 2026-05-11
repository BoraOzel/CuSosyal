//
//  CommunitiesViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 18/4/26.
//

import UIKit

protocol CommunitiesViewControllerInterface {
    func setupCollectionView()
    func setCustomFlowLayout()
    func fetchCommunities()
    func reloadData()
}

class CommunitiesViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel: CommunitiesViewModelInterface
    
    init(viewModel: CommunitiesViewModelInterface = CommunitiesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "CommunitiesViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setCustomFlowLayout()
        fetchCommunities()
    }
}

extension CommunitiesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let community = viewModel.getItem(at: indexPath.item) else { return }
        
        let detailViewModel = CommunityDetailViewModel(community: community)
        let detailVC = CommunityDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension CommunitiesViewController: UICollectionViewDataSource {
    
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

extension CommunitiesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterCommunities(with: searchText)
        reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.filterCommunities(with: "")
        reloadData()
    }
    
}

extension CommunitiesViewController: CommunitiesViewControllerInterface {
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "CommunitiesCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "CommunitiesCollectionViewCell")
        collectionView.collectionViewLayout = SingleColumnDynamicHeightFlowLayout()
    }
    
    func setCustomFlowLayout() {
        setCustomFlowLayout(lineSpacing: 10,
                            interItemSpacing: 10,
                            sectionInset: .zero,
                            estimatedItemSize: UICollectionViewFlowLayout.automaticSize)
    }
    
    func fetchCommunities() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.getCommunities()
            reloadData()
        }
    }
    
    @MainActor
    func reloadData() {
        collectionView.reloadData()
    }
    
}

extension CommunitiesViewController: DynamicFlowLayoutCustomizable {
    typealias CustomLayout = SingleColumnDynamicHeightFlowLayout
}

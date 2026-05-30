//
//  EventsViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 26/5/26.
//

import UIKit

protocol EventsViewControllerInterface {
    func setupCollectionView()
    func fetchEvents()
    func reloadData()
}

class EventsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel: EventsViewModelInterface
    
    init(viewModel: EventsViewModelInterface = EventsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "EventsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEvents()
    }
    
}

extension EventsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfEvents()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell",
                                                            for: indexPath) as? EventCollectionViewCell,
              let event = viewModel.getEvent(at: indexPath.item) else { return UICollectionViewCell() }
        let logoUrl = viewModel.getCommunity(for: event)?.logoUrl ?? ""
        cell.configure(with: event, logoUrl: logoUrl)
        return cell
    }
    
}

extension EventsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = viewModel.getEvent(at: indexPath.item) else { return }
        let community = viewModel.getCommunity(for: event)
        
        let detailVM = EventDetailViewModel(event: event, logoUrl: community?.logoUrl, adminUid: community?.adminUid)
        let detailVC = EventDetailViewController(viewModel: detailVM)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension EventsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 16
        let totalSpacing = spacing * 3
        let width = (collectionView.frame.width - totalSpacing) / 2
        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 16 }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 16 }
}

extension EventsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterEvents(with: searchText)
        reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.filterEvents(with: "")
        reloadData()
    }
}

extension EventsViewController: EventsViewControllerInterface {
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "EventCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EventCollectionViewCell")
    }
    
    func fetchEvents() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.fetchEvents()
            reloadData()
        }
    }
    
    @MainActor
    func reloadData() {
        collectionView.reloadData()
    }
    
}

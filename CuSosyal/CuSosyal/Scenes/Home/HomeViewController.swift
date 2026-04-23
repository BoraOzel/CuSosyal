//
//  HomeViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 3/3/26.
//

import UIKit

protocol HomeViewControllerInterface {
    func fetchUser()
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
        fetchUser()
    }
    
    
    @IBAction func profileButtonClicked(_ sender: Any) {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }
    
    
}

extension HomeViewController: HomeViewControllerInterface {
    
    func fetchUser() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.fetchUser()
            await MainActor.run {
                self.welcomeLabel.text = "Hoşgeldin, \(self.viewModel.userName) 👋🏻"
            }
        }
    }
    
}

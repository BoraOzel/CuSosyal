//
//  HomeViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 3/3/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var savedEventsCollectionView: UICollectionView!
    @IBOutlet weak var interestCollectionView: UICollectionView!
    @IBOutlet weak var askAiView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func profileButtonClicked(_ sender: Any) {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }
    

}

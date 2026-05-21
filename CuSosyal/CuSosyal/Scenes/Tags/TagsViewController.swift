//
//  TagsViewController.swift
//  CuSosyal
//
//  Created by Bora Özel on 16/3/26.
//

import UIKit

protocol TagSelectionDelegate: AnyObject {
    func didSelectTags(tags: [Tags])
}

protocol TagsViewControllerInterface {
    func setupCollectionView()
    func saveTags()
}

class TagsViewController: UIViewController,
                          AlertPresentable {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    typealias CustomLayout = UICollectionViewFlowLayout
    
    var selectedTags: [Tags] = []
    
    weak var delegate: TagSelectionDelegate?
    
    private let viewModel: TagsViewModelInterface
    private let allTags = Tags.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    init(viewModel: TagsViewModelInterface = TagsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "TagsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        guard selectedTags.count >= 3 else {
            showAlert(title: "Hata",
                      message: "En az 3 adet ilgi alanı seçiniz.",
                      buttonText: "Tamam")
            
            return
        }
        
        if delegate != nil {
            delegate?.didSelectTags(tags: selectedTags)
        } else {
            saveTags()
        }
        
    }
    
}

extension TagsViewController: TagsViewControllerInterface {
    
    func setupCollectionView() {
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        
        tagsCollectionView.register(UINib(nibName: "TagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagsCollectionViewCell")
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.collectionViewLayout = ThreeColumnGridFlowLayout()
    }
    
    func saveTags() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.saveTags(selectedTags)
                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                showAlert(title: "Hata",
                          message: "İlgi alanları kaydedilemedi.",
                          buttonText: "Tamam")
            }
        }
    }
}

extension TagsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTag = allTags[indexPath.row]
        
        if !selectedTags.contains(selectedTag) {
            selectedTags.append(selectedTag)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedTag = allTags[indexPath.row]
        
        if let index = selectedTags.firstIndex(of: deselectedTag) {
            selectedTags.remove(at: index)
        }
    }
    
}

extension TagsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionViewCell", for: indexPath) as! TagsCollectionViewCell
        let currentTag = allTags[indexPath.row]
        
        cell.configure(tag: currentTag)
        
        if selectedTags.contains(currentTag) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            cell.isSelected = false
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        return cell
    }
    
}

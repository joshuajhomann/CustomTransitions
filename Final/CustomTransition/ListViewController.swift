//
//  ListViewController.swift
//  CustomTransition
//
//  Created by Joshua Homann on 12/1/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    private let images: [UIImage] = (0..<10).compactMap { UIImage(named: "\($0)")}
    @IBOutlet private var layout: UICollectionViewFlowLayout!
    var selectedRect: CGRect?
    override func viewDidLoad() {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let dimension = (collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing)/2
        layout.itemSize = CGSize(width: dimension, height: dimension)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController,
            let cell = sender as? UICollectionViewCell,
            let row = collectionView.indexPath(for: cell)?.row {
            selectedRect = view.convert(cell.bounds, from: cell)
            destination.image = images[row]
            destination.index = row
        }
    }
}

class ListCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
}

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ListCollectionViewCell.self), for: indexPath)
        (cell as? ListCollectionViewCell)?.imageView.image = images[indexPath.row]
        return cell
    }
}

extension ListViewController: GrowAnimationSource {
    var growFromRect: CGRect {
        return selectedRect ?? view.bounds
    }
}

extension ListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return AnimationController.Drop()
        case .pop:
            return AnimationController.Drop(isReversed: true)
        case .none:
            return nil
        }
    }
}

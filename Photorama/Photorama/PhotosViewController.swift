//
//  ViewController.swift
//  Photorama
//
//  Created by Tung Nguyen on 12/13/19.
//  Copyright © 2019 Tung Nguyen. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate{
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        store.fetchInterestingPhotos { (photoResults) -> Void in
            switch photoResults {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                self.photoDataSource.photos = photos
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        // Download the image data, which could take some time
        store.fetchImage(for: photo) { (result) -> Void in
            
            // The index path for the photo might have changed between the
            // time the request started and finished, so find the most
            // recent index path
            
            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // When the request finishes, only update the cell if it's still visible
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath =
                collectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! PhotoInfoViewController
                
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(4)
        var paddingSpace = CGFloat(0)
        
        if let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            paddingSpace += collectionViewFlowLayout.minimumInteritemSpacing * (itemsPerRow - 1)
            paddingSpace += collectionViewFlowLayout.sectionInset.left + collectionViewFlowLayout.sectionInset.right
        }
        
        let itemWidth = ((collectionView.bounds.width - paddingSpace) / itemsPerRow).rounded(.down)
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

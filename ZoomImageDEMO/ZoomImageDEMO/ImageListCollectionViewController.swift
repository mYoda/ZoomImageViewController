//
//  ImageListCollectionViewController.swift
//  ZoomImageDEMO
//
//  Created by Anton Nechayuk on 15.07.18.
//  Copyright © 2018 Anton Nechayuk. All rights reserved.
//

import UIKit

class ImageListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
    
    override func awakeFromNib() {
        imageView?.contentMode = .scaleAspectFit
    }
}

class ImageListCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var dataSource = [[UIImage]]()
    var imageFrame: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.append([#imageLiteral(resourceName: "car1")])
        dataSource.append([#imageLiteral(resourceName: "car2"), #imageLiteral(resourceName: "car3")])
        dataSource.append([#imageLiteral(resourceName: "car4")])
        
        clearsSelectionOnViewWillAppear = true
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: (UIScreen.main.bounds.width - 30) / 2, height: 160)
        if indexPath.section % 2 == 0 {
            size = CGSize(width: UIScreen.main.bounds.width - 20, height: 200)
        }
        
        return size
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: 130)
        }
        
        return CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageListCollectionViewCell
        cell.imageView?.image = dataSource[indexPath.section][indexPath.item]
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let imageView = (collectionView.cellForItem(at: indexPath) as? ImageListCollectionViewCell)?.imageView {
            zoomImage(imageView: imageView)
        }
    }
    
    //MARK: Actions
    func zoomImage(imageView: UIImageView) {
        
        guard let imageVC = storyboard?.instantiateViewController(withIdentifier: "ZoomImageViewController") as? ZoomImageViewController
            else {
                fatalError("Cannot find view controller : ZoomImageViewController")
        }
        
        if let image = imageView.image, imageView.imageBounds() != CGRect.zero {
            //getting clear image frame (maskFrame) from UIImageView and convert it to main view coordinate system
            imageFrame = imageView.imageFrameInView(coordinateView: self.view)
            
            imageVC.image = image
            imageVC.transitioningDelegate = self
            self.present(imageVC, animated: true, completion: nil)
        }
    }
}

//MARK: UIViewControllerTransitioningDelegate
extension ImageListCollectionViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let maskFrame = imageFrame else {
            return nil
        }
        
        let presentController = ZoomImageTransitioningController(maskFrame: maskFrame, didFinishAnimations: { () -> Void in
            self.imageFrame = nil
        })
        
        return presentController
    }
}

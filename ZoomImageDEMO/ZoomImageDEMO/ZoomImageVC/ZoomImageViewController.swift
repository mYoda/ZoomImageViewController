//
//  ZoomImageViewController.swift
//  ZoomImageDEMO
//
//  Created by Anton Nechayuk on 13.07.18.
//  Copyright © 2018 Anton Nechayuk. All rights reserved.
//

import UIKit

class ZoomImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        guard let image = self.image else {
            closeButtonPressed(nil)
            return
        }
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        scrollView.frame = view.frame
        scrollView.delegate = self
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageView)
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.4
        scrollView.zoomScale = 1.0
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction))
        gesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(gesture)
        setZoomScale()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        zoomOut()
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    //MARK: Zoom
    private func setZoomScale(_ animated: Bool = false) {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        let minZoomScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minZoomScale
        let zoomScale: CGFloat = imageViewSize.width > scrollViewSize.width ? minZoomScale : 1.0
        scrollView.setZoomScale(zoomScale, animated: animated)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    fileprivate func setContentInset(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setContentInset(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = self.offset(scrollView)
        //means swipe down here
        if offset > 90 {
            zoomOut()
        }
    }
    
    private func offset(_ scrollView:UIScrollView) -> CGFloat {
        let result = scrollView.contentSize.height / scrollView.zoomScale - scrollView.frame.height - scrollView.contentOffset.y
        return max(result, 0)
    }
    
    //MARK: Actions
    @objc func tapAction() {
        if scrollView.zoomScale > 0 {
            zoomOut()
        }
    }
    
    private func zoomOut() {
        setZoomScale(true)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
}



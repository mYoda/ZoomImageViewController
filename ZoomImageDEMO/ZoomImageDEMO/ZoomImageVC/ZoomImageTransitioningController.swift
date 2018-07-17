//
//  CustomAnimatedTransitioningController.swift
//  ZoomImageDEMO
//
//  Created by Anton Nechayuk on 13.07.18.
//  Copyright © 2018 Anton Nechayuk. All rights reserved.
//


import UIKit

class ZoomImageTransitioningController: NSObject, UIViewControllerAnimatedTransitioning {
    public var maskFrame: CGRect
    private var completion: (()->Void)?
    
    init(maskFrame: CGRect, didFinishAnimations: (()->Void)?) {
        self.maskFrame = maskFrame
        completion = didFinishAnimations
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ZoomImageViewController
            else {
                return
        }
        let containerView = transitionContext.containerView
        toVC.view.frame.origin = CGPoint.zero
        let screenBounds = toVC.view.bounds
        
        let presentedViewSnapshop = self.takeSnapshot(from: toVC.view, hideView: true)
        
        presentedViewSnapshop.frame = {
            var resultImageFrame: CGRect = CGRect.zero
            
            resultImageFrame = toVC.imageView.frame
            let contentInset = toVC.scrollView.contentInset
            resultImageFrame.origin.x = contentInset.left
            resultImageFrame.origin.y = toVC.scrollView.contentOffset.y // 
            
            let scaleFactor = maskFrame.size.width / resultImageFrame.size.width
            
            let fr = CGRect(x:0,
                            y: ( resultImageFrame.origin.y * scaleFactor),
                            width: screenBounds.size.width * scaleFactor,
                            height: (screenBounds.size.height) * scaleFactor)
            return fr
        }()
        
        let presentedContainerView = UIView(frame: maskFrame)
        presentedContainerView.clipsToBounds = true
        presentedContainerView.addSubview(presentedViewSnapshop)
        
        let backgroundView = UIView(frame: fromVC.view.frame)
        backgroundView.backgroundColor = toVC.view.backgroundColor ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        let presentingViewSnapshot = self.takeSnapshot(from: fromVC.view, hideView: true)
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(backgroundView)
        containerView.addSubview(presentingViewSnapshot)
        containerView.addSubview(presentedContainerView)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            presentingViewSnapshot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            presentingViewSnapshot.alpha = 0.3
            presentedContainerView.alpha = 1
            presentedContainerView.frame = screenBounds
            
            presentedViewSnapshop.frame = CGRect(origin: CGPoint.zero, size: screenBounds.size)
        }, completion: { _ in
            backgroundView.removeFromSuperview()
            presentingViewSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            presentedContainerView.removeFromSuperview()
            toVC.view.isHidden = false
            fromVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.completion?()
        })
    }
    
    private func takeSnapshot(from view: UIView, hideView: Bool) -> UIView {
        let snapshot = view.snapshotView(afterScreenUpdates: true)
        view.isHidden = hideView
        return snapshot ?? UIView()
    }
}

extension UIImageView {
    func imageFullSize() -> CGSize {
        if let image = self.image {
            return UIImageView(image: image).bounds.size
        }
        return CGSize.zero
    }
    
    func imageSizeInFrameView() -> CGSize {
        let fullImageSize = imageFullSize()
        
        let k: CGFloat = {
            let frameScale = frame.width / frame.height
            let imageScale = fullImageSize.width / fullImageSize.height
            
            if imageScale > frameScale {
                return frame.width / fullImageSize.width
            } else {
                return frame.height / fullImageSize.height
            }
        }()
        
        let sizeInFrame = CGSize(width: k * fullImageSize.width, height: k * fullImageSize.height)
        
        return sizeInFrame
    }
    
    func imageBounds() -> CGRect {
        
        let sizeInFrame = imageSizeInFrameView()
        let originInFrame = CGPoint(x: (frame.width - sizeInFrame.width) / 2,
                                    y: (frame.height - sizeInFrame.height) / 2)
        let fFrame = CGRect(origin: originInFrame, size: sizeInFrame)
        
        return fFrame
    }
    
    func imageFrameInView(coordinateView: UIView) -> CGRect {
        
        let maskFrame = convert(frame, to: coordinateView)
        let fFrame = imageBounds()
        var yOffset = maskFrame.origin
        yOffset.y += (maskFrame.height - fFrame.height) / 2
        yOffset.x += (maskFrame.width - fFrame.width) / 2
        
        return CGRect(origin: yOffset, size: fFrame.size)
    }
}


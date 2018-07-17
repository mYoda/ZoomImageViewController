# ZoomImageViewController
Example how to make Zoom-in transition using **UIViewControllerAnimatedTransitioning**. 

<img align="left"  width="200" src="/ReadmeSources/1.png" />
<img width="200" src="/ReadmeSources/2.gif" />

---
### Usage

Pass to Loader:
* get image frame from your UIImageView and convert point to main view coordinate system

```swift
let imageFrame = imageView.imageFrameInView(coordinateView: self.view)
```

* set up and present **ZoomImageViewController** passing an image

``` swift

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

```

* add **UIViewControllerTransitioningDelegate** to your ViewController

```swift
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

```

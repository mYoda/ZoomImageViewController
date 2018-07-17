# ZoomImageViewController
Example how to make Zoom-in transition using **UIViewControllerAnimatedTransitioning**. 

<img align="left"  width="200" src="/ReadmeSources/1.png" />
<img width="200" src="/ReadmeSources/2.gif" />

---
### Usage

Pass to Loader:
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

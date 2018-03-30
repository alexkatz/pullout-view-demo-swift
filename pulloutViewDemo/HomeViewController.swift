import UIKit

class HomeViewController: UIViewController {
  let pulloutView = UIView()
  let TOP_MARGIN = CGFloat(180)
  let BOTTOM_MARGIN = CGFloat(180)
  var animator: UIViewPropertyAnimator?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(red: 3/255.0, green: 140/255.0, blue: 180/255.0, alpha: 1)
    
    pulloutView.backgroundColor = UIColor.orange
    pulloutView.frame = CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - BOTTOM_MARGIN), size: CGSize(width: view.bounds.width, height: view.bounds.height))
    pulloutView.layer.masksToBounds = false
    pulloutView.layer.shadowColor = UIColor.black.cgColor
    pulloutView.layer.shadowOffset = CGSize(width: 10, height: 10)
    pulloutView.layer.shadowOpacity = 0.8
    pulloutView.layer.shadowRadius = 20
    view.addSubview(pulloutView)
    
    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
    pulloutView.addGestureRecognizer(gestureRecognizer)
  }
  
  @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    let translationY = gestureRecognizer.translation(in: view).y
    
    switch gestureRecognizer.state {
    case .began:
      animator?.stopAnimation(true)
      fallthrough
    case .changed:
      let potentialNewY = pulloutView.frame.origin.y + translationY
      let translationFactor = getTranslationFactor(potentialNewY: potentialNewY)
      pulloutView.frame = CGRect(origin: CGPoint(x: pulloutView.frame.origin.x, y: pulloutView.frame.origin.y + (translationY * translationFactor)), size: pulloutView.frame.size)
      gestureRecognizer.setTranslation(CGPoint.zero, in: view)
      break
    case .cancelled:
      fallthrough
    case .ended:
      let y = pulloutView.frame.origin.y
      let velocityY = gestureRecognizer.velocity(in: view).y
      
      let remainingDistance = abs(pulloutView.frame.origin.y - (view.frame.size.height - BOTTOM_MARGIN))
      let initialVelocity = CGVector(dx: 0, dy: childViewExceedsBoundaries() ? 0 : velocityY / remainingDistance)
      let springParameters = UISpringTimingParameters(mass: 4.5, stiffness: 900, damping: 90, initialVelocity: initialVelocity)
      
      animator = UIViewPropertyAnimator(duration: 0, timingParameters: springParameters)
      animator?.isInterruptible = true
      animator?.addAnimations { self.pulloutView.frame = CGRect(origin: CGPoint(x: self.pulloutView.frame.origin.x, y: self.view.frame.size.height - self.BOTTOM_MARGIN), size: self.pulloutView.frame.size) }
      animator?.startAnimation()
      break
    default:
      break
    }
  }
  
  func getTranslationFactor(potentialNewY: CGFloat) -> CGFloat {
    let marginMultiplier = CGFloat(3)
    if potentialNewY < TOP_MARGIN {
      let excessDistance = TOP_MARGIN - potentialNewY
      return 0.3 - (excessDistance / (TOP_MARGIN * marginMultiplier))
    } else if potentialNewY > view.frame.size.height - BOTTOM_MARGIN {
      let excessDistance = potentialNewY - (view.frame.size.height - BOTTOM_MARGIN)
      return 0.3 - (excessDistance / (BOTTOM_MARGIN * marginMultiplier))
    }
    
    return 1
  }
  
  func childViewExceedsBoundaries() -> Bool {
    return pulloutView.frame.origin.y < TOP_MARGIN || pulloutView.frame.origin.y > view.frame.size.height - BOTTOM_MARGIN
  }
}

enum PulloutState {
  case maximized
  case minimized
}


import UIKit
import SwiftUI

class CustomTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPresentAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissAnimator()
    }
}

// Helper to configure the hosting controller with our custom transition
struct HostingControllerConfigurator: UIViewControllerRepresentable {
    let transitionManager: CustomTransitionManager
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let parent = uiViewController.parent {
            parent.modalPresentationStyle = .custom
            parent.transitioningDelegate = transitionManager
        }
    }
}

class CustomPresentationController: UIPresentationController {
    private let dimView = UIView()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        dimView.frame = containerView.bounds
        containerView.insertSubview(dimView, at: 0)
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        dimView.frame = containerView?.bounds ?? .zero
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let containerBounds = containerView.bounds
        let targetWidth = containerBounds.width
        let targetHeight = containerBounds.height * 0.85
        
        return CGRect(
            x: 0,
            y: containerBounds.height - targetHeight,
            width: targetWidth,
            height: targetHeight
        )
    }
}

class CustomPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return MotionManager.shared.viewTransitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        toViewController.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)
        containerView.addSubview(toViewController.view)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: MotionManager.shared.viewTransitionDamping,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                toViewController.view.frame = finalFrame
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}

class CustomDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return MotionManager.shared.viewTransitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        let _ = transitionContext.containerView
        let initialFrame = fromViewController.view.frame
        let finalFrame = initialFrame.offsetBy(dx: 0, dy: initialFrame.height)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: MotionManager.shared.viewTransitionDamping,
            initialSpringVelocity: 0.5,
            options: .curveEaseIn,
            animations: {
                fromViewController.view.frame = finalFrame
            },
            completion: { finished in
                if finished {
                    fromViewController.view.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
            }
        )
    }
} 
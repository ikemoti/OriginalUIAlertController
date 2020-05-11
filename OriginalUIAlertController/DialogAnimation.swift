//
//  DialogAnimation.swift
//  OriginalUIAlertController
//
//  Created by Sousuke Ikemoto on 2020/05/11.
//  Copyright © 2020 Sousuke Ikemoto. All rights reserved.
//

import UIKit

 public class DialogAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    // true: dismiss
    // false: present
    private let isPresent: Bool
    init(isPresent: Bool) {
        self.isPresent = isPresent
    }
    public func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            dismissAnimation(transitionContext)
        } else {
            presentAnimation(transitionContext)
        }
    }
    private func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let alert = transitionContext
            .viewController(forKey: UITransitionContextViewControllerKey.to) as? DialogController
            else { fatalError("ViewController is not defined sucessfully") }
        let container = transitionContext.containerView
        alert.baseView.alpha = 0
        alert.dialogStackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        container.addSubview(alert.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        alert.baseView.alpha = 1
                        alert.dialogStackView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1, animations: {
                            alert.dialogStackView.transform = CGAffineTransform.identity
                        })
                        transitionContext.completeTransition(true)
        })
    }
    private func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let alert = transitionContext
            .viewController(forKey: UITransitionContextViewControllerKey.from) as? DialogController
            else { fatalError("ViewController is not defined sucessfully") }
        UIView.animate(withDuration: 0.3, animations: {
            alert.baseView.alpha = 0
            alert.dialogStackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}


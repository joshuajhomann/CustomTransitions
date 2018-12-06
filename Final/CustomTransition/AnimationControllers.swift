//
//  AnimationController.swift
//  CustomTransition
//
//  Created by Joshua Homann on 12/1/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit

enum AnimationController {
    static let defaultTime: TimeInterval = 0.5
    class Zoom: NSObject, UIViewControllerAnimatedTransitioning {
        private let isReversed: Bool
        private static let reallySmall = CGAffineTransform(scaleX: 1e-4, y: 1e-4)
        init(isReversed: Bool = false) {
            self.isReversed = isReversed
        }
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return AnimationController.defaultTime
        }
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let destinationView = transitionContext.destinationView,
                  let sourceView = transitionContext.sourceView else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubviewIfNeeded(destinationView)
            let viewToAnimate = isReversed ? sourceView : destinationView
            viewToAnimate.transform = isReversed ? .identity : Zoom.reallySmall
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [isReversed] in
                viewToAnimate.transform = isReversed ? Zoom.reallySmall : .identity
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }

    class Drop: NSObject, UIViewControllerAnimatedTransitioning {
        private let isReversed: Bool
        init(isReversed: Bool = false) {
            self.isReversed = isReversed
        }
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return AnimationController.defaultTime
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let destinationView = transitionContext.destinationView,
                  let sourceView = transitionContext.sourceView else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubviewIfNeeded(destinationView)
            let dy = -transitionContext.containerView.bounds.height
            if !isReversed {
                destinationView.transform = .init(translationX: 0, y: dy)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
                    destinationView.transform = .identity
                }, completion: { _ in
                    transitionContext.completeTransition(true)
                })
            } else {
                transitionContext.containerView.sendSubviewToBack(destinationView)
                UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                    sourceView.transform = CGAffineTransform(rotationAngle: .pi).translatedBy(x: 0,  y: dy)
                }, completion: { _ in
                    transitionContext.completeTransition(true)
                })
            }
        }
    }
}

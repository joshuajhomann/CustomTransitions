//
//  AnimationControllers+Advanced.swift
//  CustomTransition
//
//  Created by Joshua Homann on 12/4/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit
import GPUImage

protocol GrowAnimationControllerDelegate {
    func animate(from: CGRect, duration: TimeInterval, isReversed: Bool, completion:  @escaping ()->())
}

protocol GrowAnimationSource {
    var growFromRect: CGRect { get }
}

extension AnimationController {
    class Grow: NSObject, UIViewControllerAnimatedTransitioning {
        private let isReversed: Bool
        init(isReversed: Bool = false) {
            self.isReversed = isReversed
        }
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return AnimationController.defaultTime
        }
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let source = transitionContext.viewController(forKey: isReversed ? .to : .from),
                let target = (((source as? UINavigationController)?.topViewController ?? source) as? GrowAnimationSource)?.growFromRect,
                let viewController = transitionContext.viewController(forKey: isReversed ? .from : .to),
                let delegate = viewController as? GrowAnimationControllerDelegate else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubview(viewController.view)
            delegate.animate(from: target, duration: transitionDuration(using: transitionContext), isReversed: isReversed) {
                transitionContext.completeTransition(true)
            }
        }
    }

    class Tile: NSObject, UIViewControllerAnimatedTransitioning {
        private let isReversed: Bool
        private let tilesAcross = 12
        private let tilesDown = 24
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
            let tileWidth = transitionContext.containerView.bounds.width / CGFloat(tilesAcross)
            let tileHeight = transitionContext.containerView.bounds.height / CGFloat(tilesDown)
            let flattened = UIGraphicsImageRenderer(size: transitionContext.containerView.bounds.size).image { context in
                transitionContext.containerView.drawHierarchy(in: transitionContext.containerView.bounds, afterScreenUpdates: true)
            }
            let context = UIGraphicsImageRenderer(size: CGSize(width: tileWidth, height: tileHeight))
            let tiles = (0..<tilesDown).flatMap { tileY in
                (0..<tilesAcross).compactMap { (tileX) -> UIView? in
                    let x = CGFloat(tileX)
                    let y = CGFloat(tileY)
                    let image = context.image { context in
                        flattened.draw(at: CGPoint(x: -x*tileWidth, y: -y*tileHeight))
                    }
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: x*tileWidth, y: y*tileHeight, width: tileWidth, height: tileHeight)
                    transitionContext.containerView.insertSubview(imageView, aboveSubview: sourceView)
                    return imageView
                }
            }
            tiles.forEach { transitionContext.containerView.addSubview($0)}
            if !isReversed {
                destinationView.isHidden = true
                tiles.forEach {
                    let rotation = CATransform3DMakeRotation(CGFloat(arc4random_uniform(314))/100, 0, 0, 1)
                    $0.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeTranslation(CGFloat(arc4random_uniform(1000))+250, CGFloat(arc4random_uniform(1000))+250, 0))
                    $0.alpha = 0
                }
            } else {
                sourceView.removeFromSuperview()
            }
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseOut], animations: {
                if !self.isReversed {
                    tiles.forEach {
                        $0.transform = .identity
                        $0.alpha = 1
                    }
                } else {
                    tiles.forEach {
                        let rotation = CATransform3DMakeRotation(CGFloat(arc4random_uniform(314))/100, 0, 0, 1)
                        $0.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeTranslation(CGFloat(arc4random_uniform(500))-250, CGFloat(arc4random_uniform(500))-350, 0))
                        $0.alpha = 0
                    }
                }
            }, completion: { _ in
                destinationView.isHidden = false
                tiles.forEach {$0.removeFromSuperview()}
                transitionContext.completeTransition(true)
            })
        }
    }
    class Swirl: NSObject, UIViewControllerAnimatedTransitioning {
        private let isReversed: Bool
        private var render: ( ()->() )!
        init(isReversed: Bool = false) {
            self.isReversed = isReversed
        }
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return AnimationController.defaultTime
        }
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let destinationView = transitionContext.destinationView else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubviewIfNeeded(destinationView)
            let imageView = GPUImageView(frame: transitionContext.containerView.bounds)
            let flattened = UIGraphicsImageRenderer(size: transitionContext.containerView.bounds.size).image { context in
                (!isReversed ? transitionContext.containerView.superview! : destinationView).drawHierarchy(in: transitionContext.containerView.bounds, afterScreenUpdates: true)
            }
            let destinationImage = GPUImagePicture(image: flattened)!
            destinationView.isHidden = true
            let filter = GPUImageSwirlFilter()
            filter.addTarget(imageView)
            filter.forceProcessing(at: transitionContext.containerView.bounds.size)
            filter.angle = .pi
            filter.useNextFrameForImageCapture()
            destinationImage.addTarget(filter)
            destinationImage.processImage()
            transitionContext.containerView.addSubview(imageView)
            let startTime = CACurrentMediaTime()
            let displayLink = CADisplayLink(target: self, selector: #selector(step))
            let totalTime = transitionDuration(using: transitionContext)
            let direction: CGFloat = isReversed ? 1 : -1
            render = {
                let progress = CGFloat((CACurrentMediaTime() - startTime) / totalTime)
                guard progress <  1  else {
                    displayLink.invalidate()
                    destinationView.isHidden = false
                    imageView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                    return
                }
                imageView.alpha = progress
                filter.angle = .pi/4 * (1-progress) * direction
                destinationImage.processImage()
            }
            displayLink.add(to: .current, forMode: .default)
        }

        @objc private func step(displayLink: CADisplayLink) {
            render()
        }
    }
    class MotionBlur: NSObject, UIViewControllerAnimatedTransitioning {
        private let isReversed: Bool
        private var render: ( ()->() )!
        init(isReversed: Bool = false) {
            self.isReversed = isReversed
        }
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return AnimationController.defaultTime
        }
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let destinationView = transitionContext.destinationView else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubviewIfNeeded(destinationView)
            transitionContext.containerView.setNeedsDisplay()
            let imageView = GPUImageView(frame: transitionContext.containerView.bounds)
            let flattened = UIGraphicsImageRenderer(size: transitionContext.containerView.bounds.size).image { context in
                (!isReversed ? transitionContext.containerView.superview! : destinationView).drawHierarchy(in: transitionContext.containerView.bounds, afterScreenUpdates: true)
            }
            let destinationImage = GPUImagePicture(image: flattened)!
            destinationView.isHidden = true
            let filter = GPUImageMotionBlurFilter()
            filter.addTarget(imageView)
            filter.forceProcessing(at: transitionContext.containerView.bounds.size)
            filter.blurSize = 1
            filter.useNextFrameForImageCapture()
            destinationImage.addTarget(filter)
            destinationImage.processImage()
            transitionContext.containerView.addSubview(imageView)
            let startTime = CACurrentMediaTime()
            let displayLink = CADisplayLink(target: self, selector: #selector(step))
            let totalTime = transitionDuration(using: transitionContext)
            let direction: CGFloat = isReversed ? 1 : -1
            render = {
                let progress = CGFloat((CACurrentMediaTime() - startTime) / totalTime)
                guard progress <  1  else {
                    displayLink.invalidate()
                    destinationView.isHidden = false
                    imageView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                    return
                }
                imageView.alpha = progress
                filter.blurSize = direction * 10*(1-progress) //.pi/4 * CGFloat(1-progress) * direction
                destinationImage.processImage()
            }
            displayLink.add(to: .current, forMode: .default)
        }

        @objc private func step(displayLink: CADisplayLink) {
            render()
        }
    }

    class Circle: NSObject, UIViewControllerAnimatedTransitioning {
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
            let topView = !isReversed ? destinationView : sourceView

            let layer = CAShapeLayer()
            layer.path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0),
                                      radius: hypot(destinationView.bounds.width, destinationView.bounds.height),
                                      startAngle: 0,
                                      endAngle: 2.0 * .pi,
                                      clockwise: true).cgPath
            topView.clipsToBounds = true
            topView.layer.mask = layer

            let move = CATransform3DTranslate(CATransform3DIdentity, 0, destinationView.bounds.midY, 0)
            let scale = CATransform3DScale(move, 1e-3, 1e-3, 1)

            CATransaction.begin()
            let animation = CABasicAnimation(keyPath: "transform")
            if !isReversed {
                animation.fromValue = scale
                animation.toValue = CATransform3DIdentity
            } else {
                animation.fromValue = CATransform3DIdentity
                animation.toValue = scale
            }

            animation.duration = CFTimeInterval(transitionDuration(using: transitionContext))
            CATransaction.setCompletionBlock {
                topView.layer.mask = nil
                transitionContext.completeTransition(true)
            }
            layer.add(animation, forKey: "animation")
            CATransaction.commit()
        }
    }

}


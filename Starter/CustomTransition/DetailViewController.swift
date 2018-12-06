//
//  DetailViewController.swift
//  CustomTransition
//
//  Created by Joshua Homann on 12/1/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet private var visualEffectView: UIVisualEffectView!
    @IBOutlet private var imageView: UIImageView!
    var image: UIImage?
    var index = 0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    @IBAction private func tapToDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch index {
        case 0:
            return AnimationController.Grow()
        case 1:
            return AnimationController.Swirl()
        case 2:
            return AnimationController.Tile()
        case 3:
            return AnimationController.Zoom()
        case 4:
            return AnimationController.Drop()
        case 5:
            return AnimationController.MotionBlur()
        case 6:
            return AnimationController.Circle()
        default:
            return AnimationController.Grow()
        }
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch index {
        case 0:
            return AnimationController.Grow(isReversed: true)
        case 1:
            return AnimationController.Swirl(isReversed: true)
        case 2:
            return AnimationController.Tile(isReversed: true)
        case 3:
            return AnimationController.Zoom(isReversed: true)
        case 4:
            return AnimationController.Drop(isReversed: true)
        case 5:
            return AnimationController.MotionBlur(isReversed: true)
        case 6:
            return AnimationController.Circle(isReversed: true)
        default:
            return AnimationController.Grow(isReversed: true)
        }
    }
}

extension DetailViewController: GrowAnimationControllerDelegate {
    func animate(from: CGRect, duration: TimeInterval, isReversed: Bool, completion: @escaping () -> ()) {
        if !isReversed {
            let finalFrame = imageView.frame
            imageView.frame = from
            imageView.frame.origin.y -= 96
            imageView.layer.cornerRadius = 16
            visualEffectView.effect = nil
            UIView.animate(withDuration: duration*0.8, delay: duration*0.2, options: [],
                animations: {[visualEffectView] in
                    visualEffectView?.effect = UIBlurEffect(style: .dark)
                }, completion: nil)
            UIView.animate(withDuration: duration,
                animations: { [imageView] in
                    imageView?.frame = finalFrame
                    imageView?.layer.cornerRadius = 4
                }, completion: { _ in
                    completion()
            })
        } else {
            UIView.animate(withDuration: duration*0.8, delay: duration*0.2, options: [],
                animations: {[visualEffectView] in
                    visualEffectView?.effect = nil
                }, completion: nil)
            UIView.animate(withDuration: duration,
                animations: { [imageView] in
                    imageView?.frame = from
                    imageView?.layer.cornerRadius = 16
                }, completion: { _ in
                    completion()
            })
        }

    }
}


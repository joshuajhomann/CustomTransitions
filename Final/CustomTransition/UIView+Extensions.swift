//
//  UIView+Extensions.swift
//  CustomTransition
//
//  Created by Joshua Homann on 12/3/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviewIfNeeded(_ view: UIView) {
        guard view.superview == nil else {
            return
        }
        addSubview(view)
    }
}

extension UIViewControllerContextTransitioning {
    var destinationView: UIView? {
        return view(forKey: .to) ?? viewController(forKey: .to)?.view
    }
    var sourceView: UIView? {
        return view(forKey: .from) ?? viewController(forKey: .from)?.view
    }
}

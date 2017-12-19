//
//  UIViewController+Snapping.swift
//  DynamicToss
//
//  Created by Carl Peto on 17/12/2017.
//  Copyright © Carl Peto. All rights reserved.
//  This file is my own work, based on ideas from Ray Wenderlich site.  The rest has other copyright.

import Foundation
import UIKit

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> UIOffset {
        return UIOffset(horizontal: lhs.x - rhs.x, vertical: lhs.y - rhs.y)
    }
    
    func velocityAsMagnitude() -> CGFloat {
        return (x * x + y * y).squareRoot()
    }
    
    func velocityAsVector() -> CGVector {
        return CGVector(dx: x/10, dy: y/10)
    }
}

extension CGRect {
    func centrePoint() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

let throwingSpeed: CGFloat = 2000
let speedAdjustmend: CGFloat = 1/35
let animationRunTime: TimeInterval = 0.9

class ContainsSnappingView: UIView {
    var animator: UIDynamicAnimator!
    var attachmentBehaviour: UIAttachmentBehavior!
    var snapBehaviour: UISnapBehavior!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        animator = UIDynamicAnimator(referenceView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        animator = UIDynamicAnimator(referenceView: self)
    }
    
    // set this after layout, removes constraints
    weak var snappingView: UIView? {
        didSet {
            if let snappingView = snappingView, snappingView != oldValue {
                // remove and re-add the view to remove constraints tied to our view
                // so animation can proceed smoothly
//                let frame = snappingView.frame
//                snappingView.removeFromSuperview()
//                addSubview(snappingView)
//                snappingView.frame = frame
                setupSnappingView()
                // we don't re-add constraints after the animation
            }
        }
    }

    // override point
    var dismissFinished: (() -> ())?

    func setupSnappingView() {
        let pgr = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        snappingView?.addGestureRecognizer(pgr)
    }

    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)

        guard let snappingView = snappingView else {
            return
        }
        
        let snapViewLocation = gesture.location(in: snappingView)

        switch gesture.state {
        case .began:
            animator.removeAllBehaviors()
            let offset: UIOffset = snapViewLocation - location
            attachmentBehaviour = UIAttachmentBehavior(item: snappingView, offsetFromCenter: offset, attachedToAnchor: location)
            animator.addBehavior(attachmentBehaviour!)

            snapBehaviour = UISnapBehavior(item: snappingView, snapTo: snappingView.frame.centrePoint())
            animator.addBehavior(snapBehaviour!)

        case .ended:
            if let attachmentBehaviour = attachmentBehaviour {
                animator.removeBehavior(attachmentBehaviour)
            }

            let velocity = gesture.velocity(in: self)
            let speed = velocity.velocityAsMagnitude()

            if speed > throwingSpeed {
                if let snapBehaviour = snapBehaviour {
                    animator.removeBehavior(snapBehaviour)
                }

                let pushBehaviour = UIPushBehavior(items: [snappingView], mode: .instantaneous)
                pushBehaviour.pushDirection = velocity.velocityAsVector()
                pushBehaviour.magnitude = speed * speedAdjustmend
                animator.addBehavior(pushBehaviour)

                let momentum = UIDynamicItemBehavior(items: [snappingView])
                momentum.friction = 9.2
                momentum.resistance = 1.2
                momentum.allowsRotation = true
                animator.addBehavior(momentum)

                let gravity = UIGravityBehavior(items: [snappingView])
                animator.addBehavior(gravity)
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animationRunTime) {
                self.animator.removeAllBehaviors()
                self.dismissFinished?()
            }

        default:
            attachmentBehaviour?.anchorPoint = location
        }
    }
}

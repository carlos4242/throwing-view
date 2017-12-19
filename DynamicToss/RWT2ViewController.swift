//
//  RWT2ViewController.swift
//  DynamicToss
//
//  Created by Carl Peto on 17/12/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//  This code is derived from work on Ray Wenderlich site.

import UIKit

class RWT2ViewController: UIViewController {
    
    @IBOutlet weak var containingView: ContainsSnappingView!
    @IBOutlet weak var throwableView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containingView.snappingView = throwableView
    }
}

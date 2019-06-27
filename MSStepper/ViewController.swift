//
//  ViewController.swift
//  MSStepper
//
//  Created by blet-mac on 27/06/19.
//  Copyright © 2019 BLET. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .cyan
        
        let stpr = MSStepper(frame: CGRect(x: 50, y: 100, width: 120, height: 40))
        stpr.minValue = 1
        stpr.maxValue = 10
        stpr.value = 1
        stpr.stepValue = 1
        view.addSubview(stpr)
    }


}


//
//  ViewController.swift
//  FloatingUI
//
//  Created by Nishant Taneja on 23/05/25.
//

import UIKit

class ViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FloatingView.shared.display(on: view)
    }
}


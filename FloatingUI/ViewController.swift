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
        FloatingView.shared.preferredExpandedState = .expanded
        FloatingView.shared.didUpdateToState = { [weak self] state in
            print(self, #function, state)
        }
        FloatingView.shared.didAlignToEdge = { [weak self] edge in
            print(self, #function, edge)
        }
        FloatingView.shared.didSelectActionType = { [weak self] actionType in
            print(self, #function, actionType)
            switch actionType {
            case .start:
                FloatingView.shared.preferredExpandedState = .expandedLarge
            case .interrupt:
                FloatingView.shared.preferredExpandedState = .expandedLarge
            case .stop:
                FloatingView.shared.preferredExpandedState = .expanded
            }
            FloatingView.shared.updateState(to: FloatingView.shared.preferredExpandedState)
            FloatingView.shared.alignView(to: FloatingView.shared.currentEdgeAlignment)
        }
    }
}


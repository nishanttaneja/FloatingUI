//
//  FloatingView.swift
//  FloatingUI
//
//  Created by Nishant Taneja on 23/05/25.
//

import UIKit

final class FloatingView: UIView {
    enum FloatingViewState {
        case collapsed, expanded, expandedLarge
    }
    enum FloatingViewEdgeAlignment {
        case top, left, right, bottom
    }
    
    // MARK: Properties
    static let shared = FloatingView()
    private let defaultOriginY: CGFloat = 200
    private var touchLocationOffset: CGPoint?
    private let magneticRangeOfAttraction: CGFloat = 150
    private let permittedEdgeAlignments: [FloatingViewEdgeAlignment] = [.left, .right, .top, .bottom]
    
    // MARK: Configurations
    private func configViews() {
        backgroundColor = .red
        configPanGesture()
    }
    private func alignView(to edge: FloatingViewEdgeAlignment) {
        guard permittedEdgeAlignments.contains(edge) else {
            if let firstEdgeAlignment = permittedEdgeAlignments.first {
                alignView(to: firstEdgeAlignment)
            }
            return
        }
        switch edge {
        case .top:
            frame.origin.y = superview?.safeAreaLayoutGuide.layoutFrame.origin.y ?? .zero
        case .left:
            frame.origin.x = superview?.safeAreaLayoutGuide.layoutFrame.origin.x ?? .zero
        case .bottom:
            if let superviewHeight = superview?.safeAreaLayoutGuide.layoutFrame.height {
                frame.origin.y = superviewHeight - frame.height
            }
        case .right:
            if let superviewWidth = superview?.safeAreaLayoutGuide.layoutFrame.width {
                frame.origin.x = superviewWidth - frame.width
            }
        }
    }
    func display(on view: UIView, with edgeAlignment: FloatingViewEdgeAlignment = .left) {
        removeFromSuperview()
        view.addSubview(self)
        frame.origin = CGPoint(x: .zero, y: defaultOriginY)
        frame.size = CGSize(width: 80, height: 160)
        // If don't have any saved location then align to left
        alignView(to: .left)
    }
    private func autoAlign() {
        guard let superviewSize = superview?.frame.size else {
            print(#function, ": superview size not found.")
            return
        }
        let halfWidthOfSuperview = superviewSize.width/2
        let halfHeightOfSuperview = superviewSize.height/2
        if halfWidthOfSuperview > frame.origin.x,
           frame.origin.x <= magneticRangeOfAttraction {
            alignView(to: .left)
        } else if halfWidthOfSuperview <= frame.origin.x,
                  superviewSize.width-frame.origin.x-frame.width <= magneticRangeOfAttraction {
            alignView(to: .right)
        } else if halfHeightOfSuperview > frame.origin.y,
                  frame.origin.y <= magneticRangeOfAttraction {
            alignView(to: .top)
        } else if halfHeightOfSuperview <= frame.origin.y,
                  superviewSize.height-frame.origin.y-frame.height <= magneticRangeOfAttraction {
            alignView(to: .bottom)
        } else {
            // By default aligning towards left
            alignView(to: .left)
        }
    }
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if touchLocationOffset == nil {
                touchLocationOffset = gestureRecognizer.location(in: self)
            }
        case .changed:
            let touchLocationInSuperview = gestureRecognizer.location(in: superview)
            let superviewSize = superview?.safeAreaLayoutGuide.layoutFrame.size ?? .zero
            if let touchLocationOffset {
                let newOriginX = touchLocationInSuperview.x-touchLocationOffset.x
                let newOriginY = touchLocationInSuperview.y-touchLocationOffset.y
                if newOriginX >= superview?.safeAreaLayoutGuide.layoutFrame.origin.x ?? .zero, newOriginX+frame.width <= superviewSize.width {
                    frame.origin.x = newOriginX
                } else if newOriginX < superview?.safeAreaLayoutGuide.layoutFrame.origin.x ?? .zero {
                    frame.origin.x = superview?.safeAreaLayoutGuide.layoutFrame.origin.x ?? .zero
                } else if newOriginX+frame.width > superviewSize.width {
                    frame.origin.x = superviewSize.width-frame.width
                }
                if newOriginY >= superview?.safeAreaLayoutGuide.layoutFrame.origin.y ?? .zero, newOriginY+frame.height <= superviewSize.height {
                    frame.origin.y = newOriginY
                } else if newOriginY < superview?.safeAreaLayoutGuide.layoutFrame.origin.y ?? .zero {
                    frame.origin.y = superview?.safeAreaLayoutGuide.layoutFrame.origin.y ?? .zero
                } else if newOriginY+frame.height > superviewSize.height {
                    frame.origin.y = superviewSize.height - frame.height
                }
            } else {
                frame.origin = touchLocationInSuperview
            }
        case .ended:
            touchLocationOffset = nil
            autoAlign()
        default:
            print(#function, ": '\(gestureRecognizer.state)' is not implemented.")
        }
    }
    private func configPanGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#Preview {
    ViewController()
}

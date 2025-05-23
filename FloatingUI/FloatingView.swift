//
//  FloatingView.swift
//  FloatingUI
//
//  Created by Nishant Taneja on 23/05/25.
//

import UIKit

var shouldDisplayExpendedLarge: Bool = false

final class FloatingView: UIView {
    enum FloatingViewState {
        case collapsed, expanded, expandedLarge
        
        var size: CGSize {
            switch self {
            case .collapsed:
                return CGSize(width: 40, height: 80)
            case .expanded:
                return CGSize(width: 100, height: 80)
            case .expandedLarge:
                return CGSize(width: 140, height: 160)
            }
        }
    }
    enum FloatingViewEdgeAlignment {
        case top, left, right, bottom
    }
    enum ActionType: Int {
        case start = 1, interrupt, stop
    }
    
    // MARK: Properties
    static let shared = FloatingView()
    private let defaultOriginY: CGFloat = 200
    private var touchLocationOffset: CGPoint?
    private let magneticRangeOfAttraction: CGFloat = 150
    private let permittedEdgeAlignments: [FloatingViewEdgeAlignment] = [.left, .right, .top, .bottom]
    private var currentEdgeAlignment: FloatingViewEdgeAlignment = .left
    private var currentState: FloatingViewState = .collapsed
    var didUpdateToState: ((_ state: FloatingViewState) -> Void)?
    var didAlignToEdge: ((_ edge: FloatingViewEdgeAlignment) -> Void)?
    var didSelectActionType: ((_ actionType: ActionType) -> Void)?
    
    // MARK: Views
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "greaterthan"))
        imageView.tintColor = .white
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var arrowView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.clipsToBounds = true
        view.addSubview(arrowImageView)
        NSLayoutConstraint.activate([
            arrowImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            arrowImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: FloatingViewState.collapsed.size.width).isActive = true
        return view
    }()
    private let startView = ImageLabelStackView(title: "Start", systemImageName: "microphone.circle.fill", tag: ActionType.start.rawValue)
    private let interruptView = ImageLabelStackView(title: "Interrupt", systemImageName: "playpause.circle.fill", tag: ActionType.interrupt.rawValue)
    private let stopView = ImageLabelStackView(title: "STOP", systemImageName: "stop.circle", tag: ActionType.stop.rawValue)
    private lazy var imageLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var imageLabelStackContainerView: UIView = {
        let view = UIView()
        view.addSubview(imageLabelStackView)
        NSLayoutConstraint.activate([
            imageLabelStackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 8),
            imageLabelStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            imageLabelStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            imageLabelStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageLabelStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -8),
        ])
        return view
    }()
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageLabelStackContainerView, arrowView])
        stackView.axis = .horizontal
        stackView.backgroundColor = .green
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Configurations
    private func configContentStackView() {
        addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentStackView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            contentStackView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    private func configViews() {
        clipsToBounds = true
        backgroundColor = .red
        configPanGesture()
        configArrowView()
        configContentStackView()
        configActionTypes()
    }
    
    // MARK: ActionTypes
    @objc private func handleActionType(forTap gestureRecognizer: UITapGestureRecognizer) {
        guard let tag = gestureRecognizer.view?.tag, let actionType = ActionType(rawValue: tag) else { print(#function, ": `ActionType` not found"); return }
        print(#function, actionType)
        shouldDisplayExpendedLarge = actionType == .start
        didSelectActionType?(actionType)
    }
    private func configActionTypes() {
        startView.isUserInteractionEnabled = true
        startView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleActionType(forTap:))))
        interruptView.isUserInteractionEnabled = true
        interruptView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleActionType(forTap:))))
        stopView.isUserInteractionEnabled = true
        stopView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleActionType(forTap:))))
    }
    
    // MARK: Update State
    @objc private func handleArrowTap(gestureRecognizer: UITapGestureRecognizer) {
        switch currentState {
        case .collapsed:
            // If recording then update to expandedLarge or else recording
            updateState(to: shouldDisplayExpendedLarge ? .expandedLarge : .expanded)
        case .expanded, .expandedLarge:
            updateState(to: .collapsed)
        }
        alignView(to: currentEdgeAlignment)
    }
    private func configArrowView() {
        let arrowTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleArrowTap(gestureRecognizer:)))
        arrowView.addGestureRecognizer(arrowTapGestureRecognizer)
    }
    /// Updates state of view.
    private func updateState(to newState: FloatingViewState) {
        currentState = newState
        startView.removeFromSuperview()
        interruptView.removeFromSuperview()
        stopView.removeFromSuperview()
        switch newState {
        case .collapsed:
            imageLabelStackContainerView.removeFromSuperview()
        case .expanded:
            imageLabelStackView.addArrangedSubview(startView)
            contentStackView.insertArrangedSubview(imageLabelStackContainerView, at: .zero)
        case .expandedLarge:
            imageLabelStackView.addArrangedSubview(interruptView)
            imageLabelStackView.addArrangedSubview(stopView)
            contentStackView.insertArrangedSubview(imageLabelStackContainerView, at: .zero)
        }
        frame.size = newState.size
        arrowImageView.image = imageFor(state: newState, atEdge: currentEdgeAlignment)
        didUpdateToState?(newState)
    }
    private func imageFor(state: FloatingViewState, atEdge edgeAlignment: FloatingViewEdgeAlignment) -> UIImage? {
        let greaterThanImage = UIImage(systemName: "greaterthan")
        let lessThanImage = UIImage(systemName: "lessthan")
        switch state {
        case .collapsed:
            return edgeAlignment == .right ? lessThanImage : greaterThanImage
        case .expanded, .expandedLarge:
            return edgeAlignment == .right ? greaterThanImage : lessThanImage
        }
    }
    
    // MARK: Show/Hide
    /// Invoke this method to display the shared instance on a specific view.
    func display(on view: UIView, atEdge edgeAlignment: FloatingViewEdgeAlignment = .left, withState state: FloatingViewState = .expandedLarge) {
        removeFromSuperview()
        view.addSubview(self)
        frame.origin = CGPoint(x: .zero, y: defaultOriginY)
        frame.size = CGSize(width: 80, height: 160)
        // If don't have any saved location then align to left
        alignView(to: edgeAlignment)
        // If don't have any saved state then use collapsed
        updateState(to: state)
    }
    
    // MARK: Align
    /// Aligns the view to a specific edge.
    private func alignView(to edge: FloatingViewEdgeAlignment) {
        guard permittedEdgeAlignments.contains(edge) else {
            if let firstEdgeAlignment = permittedEdgeAlignments.first {
                alignView(to: firstEdgeAlignment)
            }
            return
        }
        currentEdgeAlignment = edge
        arrowView.removeFromSuperview()
        switch edge {
        case .top:
            frame.origin.y = superview?.safeAreaLayoutGuide.layoutFrame.origin.y ?? .zero
            contentStackView.axis = .vertical
            contentStackView.addArrangedSubview(arrowView)
        case .left:
            frame.origin.x = superview?.safeAreaLayoutGuide.layoutFrame.origin.x ?? .zero
            contentStackView.axis = .horizontal
            contentStackView.addArrangedSubview(arrowView)
        case .bottom:
            if let superviewHeight = superview?.safeAreaLayoutGuide.layoutFrame.height {
                frame.origin.y = superviewHeight - frame.height
            }
            contentStackView.axis = .vertical
            contentStackView.insertArrangedSubview(arrowView, at: .zero)
        case .right:
            if let superviewWidth = superview?.safeAreaLayoutGuide.layoutFrame.width {
                frame.origin.x = superviewWidth - frame.width
            }
            contentStackView.axis = .horizontal
            contentStackView.insertArrangedSubview(arrowView, at: .zero)
        }
        didAlignToEdge?(edge)
    }
    /// Automatically attaches to the nearest edge
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
        updateState(to: currentState)
    }
    
    // MARK: PanGestureRecognizer
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

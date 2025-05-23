//
//  ImageLabelStackView.swift
//  FloatingUI
//
//  Created by Nishant Taneja on 23/05/25.
//

import UIKit

final class ImageLabelStackView: UIStackView {
    // MARK: Views
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "photo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return imageView
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Configurations
    private func configViews() {
        axis = .vertical
        addArrangedSubview(imageView)
        addArrangedSubview(label)
    }
    
    // MARK: Constructors
    init(title: String, systemImageName: String, tag: Int) {
        super.init(frame: .zero)
        label.text = title
        imageView.image = UIImage(systemName: systemImageName)
        self.tag = tag
        configViews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

//
//  GFAlertContainerView.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 25/02/2023.
//

import UIKit

class GFAlertContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(backgroundColor: UIColor, borderColor: CGColor) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.layer.borderColor = borderColor
        configure()
    }
    
    // by making this private, it can only be called within this class
    private func configure() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        translatesAutoresizingMaskIntoConstraints = false
    }

}

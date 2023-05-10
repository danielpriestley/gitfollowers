//
//  GFButton.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 21/02/2023.
//

import UIKit

class GFButton: UIButton {
    
    // As we are making a custom subclass of UIButton, we need to override the initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame) /// Get all the methods and functionality that Apple have added in to the UIButton
        configure()
    }
    
    // this init gets called when you use this in a storyboard, we don't need it here
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(backgroundColor: UIColor, title: String) {
        super.init(frame: .zero) // this is zero because we know that we are going to change the height/width with constraints
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
        configure()
        
    }
    
    // by making this private, it can only be called within this class
    private func configure() {
        layer.cornerRadius = 10
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func set(backgroundColor: UIColor, title: String) {
        self.backgroundColor = backgroundColor
        setTitle(title, for: .normal)
    }
    
    

}

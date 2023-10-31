//
//  GFAvatarImageView.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 04/03/2023.
//

import UIKit

class GFAvatarImageView: UIImageView {
    
    let cache = NetworkManager.shared.cache
    // we can force unwrap this because we know for sure it's in our bundle, if it was downloaded from the internet, it couldn't be guaranteed
    let placeholderImage = UIImage(named: "avatar-placeholder")!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }

}

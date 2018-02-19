//
//  SubredditLoaderFooterView.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/17/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

class SubredditLoaderFooterView: UITableViewHeaderFooterView {
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        activityIndicator.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicator.center = CGPoint(x: contentView.bounds.midX,
                                                y: contentView.bounds.midY)
    }
}

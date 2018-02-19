//
//  SubredditEmptyFooterView.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/18/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import UIKit

class SubredditEmptyFooterView: UITableViewHeaderFooterView {
    private let textView = SubredditEmptyFooterTextView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isOpaque = false
        contentView.addSubview(textView)
        textView.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.textView.frame = contentView.bounds
    }
}

fileprivate class SubredditEmptyFooterTextView: UIView {
    override func draw(_ rect: CGRect) {
        let bounds = self.bounds
        let string = NSAttributedString(string: "No more posts",
                                        attributes: [
                                            .font: UIFont.systemFont(ofSize: 16.0),
                                            .foregroundColor: UIColor.gray])
        
        let bounding = string.boundingRect(with: bounds.insetBy(dx: 20.0, dy: 0.0).size,
                                           options: [], context: nil)
        
        let rect = CGRect(origin: CGPoint(x: (bounds.width - bounding.width) / 2.0,
                                          y: (bounds.height - bounding.height) / 2.0),
                          size: bounding.size)
        
        
        string.draw(in: rect)
    }
}

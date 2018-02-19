//
//  SubredditPostTableViewCell.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

enum SubredditPostCellContentItem {
    case preview(URL)
    case subreddit(String)
    case post(RedditPost)
}

protocol SubredditPostCellSelectionDelegate: class {
    func cell(_ cell: SubredditPostTableViewCell, didSelectContentItem item: SubredditPostCellContentItem)
}

class SubredditPostTableViewCell: UITableViewCell {
    weak var delegate: SubredditPostCellSelectionDelegate? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        isOpaque = true
        backgroundColor = .white
        contentView.isHidden = true
        
        gestureRecognizer.addTarget(self, action: #selector(gestureRecognizerDidTap(sender:)))
        addGestureRecognizer(gestureRecognizer)
    }
    
    var node: SubredditPostTableViewNode? = nil {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), let node = node
            else { return }
        
        ctx.saveGState()
        
        let pixel = 1.0 / UIScreen.main.scale
        let bounds = self.bounds
        
        node.author.draw(in: node.layout.author)
        node.title.draw(in: node.layout.title)
        node.humanReadableNumberOfComments.draw(in: node.layout.comments)
        node.humanReadableDate.draw(in: node.layout.date)
        
        ctx.setFillColor(UIColor.lightGray.cgColor)
        ctx.fill(CGRect(x: 0.0, y: bounds.height - pixel, width: bounds.width, height: pixel))
        
        ctx.restoreGState()
    }
    
    private let gestureRecognizer = UITapGestureRecognizer()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SubredditImagedPostTableViewCell: SubredditPostTableViewCell {
    private let thumbnailImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        thumbnailImageView.layer.cornerRadius = 4.0
        thumbnailImageView.layer.masksToBounds = true
        thumbnailImageView.backgroundColor = .lightGray
        
        addSubview(thumbnailImageView)
    }
    
    override var node: SubredditPostTableViewNode? {
        didSet { setNeedsLayout() }
    }
    
    var thumbnailImage: UIImage? {
        get { return thumbnailImageView.image }
        set { thumbnailImageView.image = newValue }
    }
    var thumbnailObservable: Observable<UIImage>? = nil
    
    func subscribeThumbnail() {
        subscription = thumbnailObservable.map { $0
            .observe(on: .main)
            .subscribe(target: self, onNext: { $0.thumbnailImage = $1 })
            .unsubcribedOnDeinit()
        }
    }
    
    func unsubscribeThumbnail() {
        subscription = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let node = node else { return }
        thumbnailImageView.frame = node.layout.thumbnail
    }
    
    override func prepareForReuse() {
        thumbnailImage = nil
        thumbnailObservable = nil
        subscription = nil
    }
    
    private var subscription: DisposableType? = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SubredditPostTableViewCell {
    @objc fileprivate func gestureRecognizerDidTap(sender: UITapGestureRecognizer) {
        guard let node = node
            else { return }
        
        let layout = node.layout
        
        switch sender.location(in: self) {
        case let point where layout.thumbnail.contains(point):
            if let url = node.post.thumbnail {
                delegate?.cell(self, didSelectContentItem: .preview(url))
            }
            
        case let point where layout.author.contains(point):
            delegate?.cell(self, didSelectContentItem: .subreddit(node.post.subreddit))
        
        default:
            delegate?.cell(self, didSelectContentItem: .post(node.post))
        }
    }
}

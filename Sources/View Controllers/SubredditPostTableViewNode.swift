//
//  PostTableViewNode.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/16/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

struct SubredditPostTableViewNode {
    let post: RedditPost
    let title: NSAttributedString
    let author: NSAttributedString
    let humanReadableNumberOfComments: NSAttributedString
    let humanReadableDate: NSAttributedString
    let layout: Layout
    
    init(post: RedditPost, width: CGFloat) {
        let textColor = UIColor.black
        
        self.title = NSAttributedString(string: post.title,
            attributes: [
                .font : UIFont.systemFont(ofSize: 16.0, weight: .semibold),
                .foregroundColor : textColor])
        
        self.author = NSAttributedString(string: "\(post.subreddit) · \(post.author)",
            attributes: [
                .font : UIFont.systemFont(ofSize: 13.0, weight: .medium),
                .foregroundColor : textColor])
        
        self.humanReadableNumberOfComments = NSAttributedString(string: "\(post.numberOfComments) comments",
            attributes: [
                .font : UIFont.systemFont(ofSize: 12.0, weight: .regular),
                .foregroundColor : textColor])
        
        self.humanReadableDate = NSAttributedString(string: post.created.timeAgoSinceNow(),
            attributes: [
                .font : UIFont.systemFont(ofSize: 12.0, weight: .light),
                .foregroundColor : textColor])
        
        self.post = post
        self.layout = Layout(width: width,
                             title: title,
                             author: author,
                             humanReadableNumberOfComments: humanReadableNumberOfComments,
                             humanReadableDate: humanReadableDate,
                             hasThumbnail: post.thumbnail != nil)
        
    }
    
    struct Layout {
        let height: CGFloat
        let title: CGRect
        let author: CGRect
        let date: CGRect
        let thumbnail: CGRect
        let comments: CGRect
        
        init(width: CGFloat,
             title: NSAttributedString,
             author: NSAttributedString,
             humanReadableNumberOfComments: NSAttributedString,
             humanReadableDate: NSAttributedString,
             hasThumbnail: Bool) {
            
            let contentInset = CGFloat(20.0)
            let imageSize = CGFloat(hasThumbnail ? 80.0 : 0.0)
            
            let availableWidth = width - 2.0 * contentInset
            let availableTextWidth = hasThumbnail ? availableWidth - contentInset - imageSize : availableWidth
            
            let interItemMargin = CGFloat(3.0)
            
            let titleBounding = title
                .boundingRect(with: CGSize(width: availableTextWidth, height: .infinity),
                              options: [.usesLineFragmentOrigin],
                              context: nil)
            
            let authorBounding = author
                .boundingRect(with: CGSize(width: availableTextWidth, height: .infinity),
                              options: [.usesLineFragmentOrigin],
                              context: nil)
            
            let commentsBounding = humanReadableNumberOfComments
                .boundingRect(with: CGSize(width: availableTextWidth, height: .infinity),
                              options: [.usesLineFragmentOrigin],
                              context: nil)
            
            let dateBounding = humanReadableDate
                .boundingRect(with: CGSize(width: availableTextWidth, height: .infinity),
                              options: [.usesLineFragmentOrigin],
                              context: nil)
            
            let contentSize =
                    titleBounding.height + interItemMargin +
                    authorBounding.height + interItemMargin +
                    commentsBounding.height + interItemMargin +
                    dateBounding.height
            
            let leftYOffset = max(0.0, contentSize - imageSize) / 2.0 + contentInset
            let leftXOffset = contentInset
            let rightYOffset = max(0.0, imageSize - contentSize) / 2.0 + contentInset
            let rightXOffset = availableWidth - availableTextWidth + contentInset
            
            self.title = CGRect(origin: CGPoint(x: rightXOffset, y: rightYOffset),
                                size: titleBounding.size)
            
            self.author = CGRect(origin: CGPoint(x: rightXOffset, y: self.title.maxY + interItemMargin),
                                 size: authorBounding.size)
            
            self.comments = CGRect(origin: CGPoint(x: rightXOffset, y: self.author.maxY + interItemMargin),
                                   size: commentsBounding.size)
            
            self.date = CGRect(origin: CGPoint(x: rightXOffset, y: self.comments.maxY + interItemMargin),
                               size: dateBounding.size)
            
            self.thumbnail = CGRect(x: leftXOffset, y: leftYOffset,
                                    width: imageSize, height: imageSize)
            
            self.height = (self.date.maxY + contentInset).rounded(.up)
        }
    }
}

//
//  ImageManager.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/18/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation
import UIKit

protocol ImageManagerType {
    func image(`for` url: URL) -> UIImage?
    func downloadImage(at url: URL, preprocessor: @escaping (UIImage) -> (UIImage)) -> Observable<UIImage>
}

class ImageManager: ImageManagerType {
    enum Error: Swift.Error {
        case malformedImage
    }
    
    private let session: URLSession
    private let queue = DispatchQueue(label: "org.pawlowski.Reddit.image.downloading", qos: .userInitiated)
    
    private var cache: [URL : UIImage] = [:]
    private var lock = Lock()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func image(`for` url: URL) -> UIImage? {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.cache[url]
    }
    
    func downloadImage(at url: URL, preprocessor: @escaping (UIImage) -> (UIImage)) -> Observable<UIImage> {
        return .create { observer in
            if let image = self.image(for: url) {
                observer.onNext(image)
                observer.onComplete()
                return Disposable()
            }
            
            let handler = Observer<Data>(
                onNext: { data in
                    if let image = UIImage(data: data) {
                        let preprocessed = preprocessor(image)
                        self.lock.lock()
                        self.cache[url] = preprocessed
                        self.lock.unlock()
                        observer.onNext(preprocessed)
                        observer.onComplete()
                    }
                    else {
                        observer.onError(Error.malformedImage)
                    }
                },
                onComplete: observer.onComplete,
                onError: observer.onError)
            
            return self.session.data(at: url)
                .observe(on: self.queue)
                .subscribe(handler)
        }
    }
}

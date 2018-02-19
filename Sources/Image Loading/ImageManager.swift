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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func image(`for` url: URL) -> UIImage? {
        return self.cache[url]
    }
    
    func downloadImage(at url: URL, preprocessor: @escaping (UIImage) -> (UIImage)) -> Observable<UIImage> {
        return .create { observer in
            var subscription: DisposableType? = nil
            
            self.queue.async {
                if let image = self.image(for: url) {
                    subscription = Observable.value(image).subscribe(target: observer)
                }
                else {
                    let handler = Observer<Data>(
                        onNext: { data in
                            if let image = UIImage(data: data) {
                                let preprocessed = preprocessor(image)
                                self.cache[url] = preprocessed
                                observer.onNext(preprocessed)
                                observer.onComplete()
                            }
                            else {
                                observer.onError(Error.malformedImage)
                            }
                        },
                        onComplete: observer.onComplete,
                        onError: observer.onError)
                    
                    subscription = self.session.data(at: url)
                        .observe(on: self.queue)
                        .subscribe(handler)
                }
            }
            
            return Disposable { subscription?.dispose() }
        }
    }
}

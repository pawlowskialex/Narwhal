//
//  URLSession+Reactive.swift
//  Reddit
//
//  Created by Alex Pawlowski on 2/18/18.
//  Copyright © 2018 Alex Pawlowski. All rights reserved.
//

import Foundation

extension URLSession {
    func data(at url: URL) -> Observable<Data> {
        return .create { observer in
            let task = self.dataTask(with: url) { data, _, error in
                if let data = data {
                    observer.onNext(data)
                    observer.onComplete()
                }
                else if let error = error {
                    observer.onError(error)
                }
            }
            
            task.resume()
            
            return Disposable(task.cancel)
        }
    }
}

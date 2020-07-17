//
//  String + append.swift
//  App
//
//  Created by Amir Hossein on 7/17/20.
//

import Foundation

extension String {
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: .utf8)
        try data?.append(fileURL: fileURL)
    }
}

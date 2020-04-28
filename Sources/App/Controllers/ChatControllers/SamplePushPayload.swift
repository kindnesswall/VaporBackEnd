//
//  SamplePushPayload.swift
//  App
//
//  Created by Amir Hossein on 4/28/20.
//

import Vapor

final class SamplePushPayload: Content, PushPayloadable {
    var pushMainPath: String { return "sample" }
    var pushSupplementPath: String? { return nil }
    var pushQueryItems: [URLQueryItem] { return [] }
    var pushContentName: String? { return nil }
}

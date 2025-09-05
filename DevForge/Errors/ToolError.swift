//
//  ToolError.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-04.
//

import SwiftUI

enum ToolError: Error, LocalizedError {
    case parsingFailed(format: String, reason: String)

    var errorDescription: String? {
        switch self {
        case .parsingFailed(let format, let reason):
            return "\(format): \(reason)"
        }
    }
}

enum FormatError: Error, LocalizedError {
    case serializationFailed
    case deserializationFailed

    var localizedDescription: LocalizedStringKey {
        switch self {
        case .serializationFailed: "Serialization Failed"
        case .deserializationFailed: "Deserialization Failed"
        }
    }
}

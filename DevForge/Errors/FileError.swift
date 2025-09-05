//
//  FileError.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-04.
//

import SwiftUI

enum FileError: Error, LocalizedError {
    case fileNotFound
    case loadFileFailed
    case incorrectAddress
    case typeError

    var localizedDescription: LocalizedStringKey {
        switch self {
        case .fileNotFound: "File not found"
        case .loadFileFailed: "Load file failed"
        case .incorrectAddress: "Failed to convert file address"
        case .typeError: "Unsupported file type or failed to access file"
        }
    }
}

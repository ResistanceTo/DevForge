//
//  FormatterUtils.swift
//  DevForge
//
//  Created by resistanceto on 2025-09-04.
//
import Foundation

@MainActor
enum FormatterUtils {
    static func beautifyJSONFromString(from string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw FormatError.serializationFailed
        }

        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let beautifiedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])

        guard let beautifiedString = String(data: beautifiedData, encoding: .utf8) else {
            throw FormatError.deserializationFailed
        }

        return beautifiedString
    }

    static func beautifyJSONFromData(from data: Data) throws -> String {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let beautifiedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])

        guard let beautifiedString = String(data: beautifiedData, encoding: .utf8) else {
            throw FormatError.deserializationFailed
        }

        return beautifiedString
    }
}

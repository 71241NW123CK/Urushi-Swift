//
//  Disk.swift
//  Gloss
//
//  Created by Ryan Hiroaki Tsukamoto on 1/20/18.
//

import Foundation
import Gloss

public struct Disk { // This is a blatant, inferior ripoff of https://github.com/saoudrizwan/Disk.git
    public enum Directory {
        case documents
        case caches
        case applicationSupport
        
        var searchPathDirectory: FileManager.SearchPathDirectory {
            get {
                switch self {
                case .documents:
                    return .documentDirectory
                case .caches:
                    return .cachesDirectory
                case .applicationSupport:
                    return .applicationSupportDirectory
                }
            }
        }
    }
    
    public typealias Key = (directory: Directory, path: String)
    
    static func put(at key: Key, _ data: Data) throws {
        guard let url = maybeUrl(at: key) else {
            throw createError(description: "cannot get URL in \(key.directory) for path \(key.path)")
        }
        do {
            try ensureContainingDirectoryExists(for: url)
            try data.write(to: url, options: .atomic)
        } catch {
            throw error
        }
    }
    
    static func put<T: Glossy>(at key: Key, _ glossyValue: T) throws {
        guard let json = glossyValue.toJSON() else {
            throw createError(description: "could not serialize thing")
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            try put(at: key, data)
        } catch {
            throw error
        }
    }
    
    static func put(at key: Key, _ integer: Int) throws {
        let nsNumber = NSNumber(value: integer)
        let data = NSKeyedArchiver.archivedData(withRootObject: nsNumber)
        do {
            try put(at: key, data)
        } catch {
            throw error
        }
    }
    
    static func maybeGetData(at key: Key) throws -> Data? {
        guard let url = maybeUrl(at: key) else {
            throw createError(description: "cannot get URL in \(key.directory) for path \(key.path)")
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            throw error
        }
    }
    
    static func maybeGetGlossyValue<T: Glossy>(at key: Key) throws -> T? {
        do {
            let maybeData = try maybeGetData(at: key)
            guard let data = maybeData else {
                return nil
            }
            guard let glossyValue = T(data: data) else {
                throw createError(description: "cannot deserialize thing")
            }
            return glossyValue
        } catch {
            throw error
        }
    }
    
    static func maybeGetInt(at key: Key) throws -> Int? {
        do {
            let maybeData = try maybeGetData(at: key)
            guard let data = maybeData else {
                return nil
            }
            guard let nsNumber = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSNumber else {
                throw createError(description: "cannot unarchive NSNumber-wrapped integer")
            }
            return nsNumber.intValue
        } catch {
            throw error
        }
    }
    
    static func remove(_ key: Key) throws {
        guard let url = maybeUrl(at: key) else {
            throw createError(description: "cannot get URL in \(key.directory) for path \(key.path)")
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw error
        }
    }
    
    static func maybeUrl(at key: Key) -> URL? {
        // TODO: check path for validity
        let filePrefix = "file://"
        let searchPathDirectory = key.directory.searchPathDirectory
        guard var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first else {
            return nil
        }
        url = url.appendingPathComponent(key.path)
        if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
            return URL(string: filePrefix + url.absoluteString)
        }
        return url
    }
    
    static func ensureContainingDirectoryExists(for url: URL) throws {
        do {
            let containingDirectoryUrl = url.deletingLastPathComponent()
            var containingDirectoryUrlIsDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: containingDirectoryUrl.path, isDirectory: &containingDirectoryUrlIsDirectory) {
                if !containingDirectoryUrlIsDirectory.boolValue {
                    throw createError(description: "Containing directory exists, but is not a directory!  A conundrum")
                }
            } else {
                try FileManager.default.createDirectory(at: containingDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            throw error
        }
    }
    
    static func createError(description: String) -> Error {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: description];
        return NSError(domain: "Disk", code: 0, userInfo: userInfo) as Error
    }
}

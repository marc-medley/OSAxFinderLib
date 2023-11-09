//
//  OSAxFinderItem.swift
//  
//
//  Created by mc on 2023.11.07.
//

import Foundation

public enum OSAxFinderItemKind {
    case alias
    case folder
    /// Both flat and package files recognized as `file`
    case file
    case link
}

public struct OSAxFinderItemList: Codable {
    let osaxSelection: [OSAxFinderItem]
}

public struct OSAxFinderItem: Codable {
    let osaxKind: String
    let osaxPath: String
    
    var kind: OSAxFinderItemKind {
        if isDir { return .folder }
        if isFile { return .file }
        if isAlias { return .alias }
        return .link
    }
    
    var path: String {
        // Disallowed macOS filename characters are `0x00` and `:`.
        // POSIX path will replace `:` with `/` when resolving to path segment names
        let p = osaxPath
            .replacingOccurrences(of: "/", with: "\0")
            .replacingOccurrences(of: ":", with: "/")
            .replacingOccurrences(of: "\0", with: ":")
        return "/Volumes/\(p)"
    }
    
    var url: URL {
        let hint: URL.DirectoryHint = isDir ? .isDirectory : .notDirectory
        return URL(filePath: path, directoryHint: hint)
    }
    
    var urlResolved: URL? {
        var thisUrl: URL = url
        if osaxKind == "Alias" {
            let options: URL.BookmarkResolutionOptions = [.withoutUI, .withoutMounting]
            guard let original = try? URL(resolvingAliasFileAt: url, options: options)
            else { return nil }
            thisUrl = original
        }
        let fm = FileManager.default
        let path = thisUrl.path(percentEncoded: false)
        if fm.fileExists(atPath: path) {
            return thisUrl
        } else {
            return nil
        }
    }
    
    // MARK: - isThis, isThat, …
    
    var isAlias: Bool {
        if osaxKind != "Alias" { return false }
        
        var keys = Set<URLResourceKey>()
        keys.insert(.isAliasFileKey)
        keys.insert(.isSymbolicLinkKey)
        guard let values: URLResourceValues = try? url.resourceValues(forKeys: keys)
        else { return false }
        
        if values.isAliasFile == true,
           values.isSymbolicLink == false {
            return true
        }
        return false
    }
    
    
    var isDir: Bool {
        return osaxKind == "Folder"
    }
    
    var isDirWhenResolved: Bool? {
        if isDir { return true }
        guard let rurl = urlResolved else { return nil }
        
        var keys = Set<URLResourceKey>()
        keys.insert(.isDirectoryKey)
        guard let values: URLResourceValues = try? rurl.resourceValues(forKeys: keys)
        else { return nil }
        
        if values.isDirectory == true { return true }
        return false
    }

    var isFile: Bool {
        if osaxKind != "Alias", osaxKind != "Folder" {
            return true
        }
        return false
    }
    
    var isLink: Bool {
        if osaxKind != "Alias" { return false }
        
        var keys = Set<URLResourceKey>()
        keys.insert(.isAliasFileKey)
        keys.insert(.isSymbolicLinkKey)
        guard let values: URLResourceValues = try? url.resourceValues(forKeys: keys)
        else { return false }
        
        if values.isAliasFile == true,
           values.isSymbolicLink == true {
            return true
        }
        return false
    }
    
    // item exists after resolving any alias|link
    var isValid: Bool {
        var thisUrl: URL = url
        if osaxKind == "Alias" {
            let options: URL.BookmarkResolutionOptions = [.withoutUI, .withoutMounting]
            guard let original = try? URL(resolvingAliasFileAt: url, options: options)
            else { return false }
            thisUrl = original
        }
        
        let fm = FileManager.default
        let path = thisUrl.path(percentEncoded: false)
        return fm.fileExists(atPath: path)
    }
    
}


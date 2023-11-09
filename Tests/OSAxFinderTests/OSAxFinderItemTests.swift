//
//  OSAxFinderItemTests.swift
//  
//
//  Created by mc on 2023.11.07.
//

import XCTest
@testable import OSAxFinderLib

final class OSAxFinderItemTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let json = """
    { "osaxSelection": [{"osaxKind":"Folder", "osaxPath":"HD:Users:username:Desktop:arrow:"}, {"osaxKind":"Alias", "osaxPath":"HD:Users:username:Desktop:arrow_alias >"}, {"osaxKind":"Alias", "osaxPath":"HD:Users:username:Desktop:arrow_lns »"}] }
    """.data(using: .utf8)!
    
    func doDecode() {
        // ----- decode -----
        let decoder = JSONDecoder()
        guard let items = try? decoder.decode(OSAxFinderItemList.self, from: json) else {
            fatalError("OSAxFinderItemTests decode")
        }
        print(items.osaxSelection.count)
        print("OSAxFinderItemTests doDecode() completed")
    }
    
    func doEncode() {
        // ----- encode -----
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let a = OSAxFinderItem(osaxKind: "Alias", osaxPath: "HD:Users:username:filename")
        let b = OSAxFinderItem(osaxKind: "Folder", osaxPath: "HD:Users:username:foldername")
        let items = OSAxFinderItemList(osaxSelection: [a, b])
        
        print("Encoding Result:")
        guard let encodedList = try? encoder.encode(items) else {
            fatalError("OSAxFinderItemTests encode")
        }
        print(String(data: encodedList, encoding: .utf8)!)
        
        print("OSAxFinderItemTests doEncode() completed")
    }
    
    /// View raw json
    func doFetchJson() {
        let osaxFinder = OSAxFinder()        
        let urlList = osaxFinder.selectedItemsJson(printStdio: true)
        print(urlList ?? "Data is nil")
    }
    
    /// Select some files & folders, then check the following output
    func doMethod() {
        let osaxFinder = OSAxFinder()
        let list = osaxFinder.selectedItemsList()
        print("-----------------")
        for item in list {
            var s = """
            \(item.osaxPath)
            \(item.path)
            \(item.url.path(percentEncoded: false))
            \(item.urlResolved?.path(percentEncoded: false) ?? "PATH NOT RESOLVED")
            \(item.osaxKind) -> \(item.kind)\n
            """
            s.append("alias:\(item.isAlias) dir:\(item.isDir) ")
            if let dirResolved: Bool = item.isDirWhenResolved {
                s.append("dirResolved:\(dirResolved) ")
            } else {
                s.append("dirResolved:NA ")
            }
            s.append("file:\(item.isFile) link:\(item.isLink) valid:\(item.isValid)\n")
            s.append("-----------------")
            print(s)
        }
    }
    
    func testSuite() throws {
        //doDecode()
        //doEncode()
        //doFetchJson()
        //doMethod()
        
        print("OSAxFinderItemTests testSuite() completed")
    }
    
}

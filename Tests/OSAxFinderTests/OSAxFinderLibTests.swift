//
//  OSAxFinderLibTests.swift
//  OSAxFinder
//

import XCTest
@testable import OSAxFinderLib

class OSAxFinderLibTests: XCTestCase {
    
    func skipTestFindUrls() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual("A", "A")
        
        let osaxFinder = OSAxFinder()
        
        print("""
        \n------------------------------------
        ------- SELECTED FOLDER URLS -------
        """)
        var urlList = osaxFinder.selectedFolderUrls(printStdio: true)
        print("--- url list ---\n\(urlList)\n")
        
        print("""
        ----------------------------------
        ------- SELECTED FILE URLS -------
        """)
        urlList = osaxFinder.selectedFileUrls(printStdio: true)
        print("--- url list ---\n\(urlList)\n")
        for url in urlList {
            print(url.absoluteString)
        }
        print("")
        
        print("""
        ----------------------------
        ------- FRONT WINDOW -------
        """)
        if let urlList = osaxFinder.directoryFrontWindow(printStdio: true) {
            print("--- url list ---\n\(urlList)\n")
        } else {
            print("--- no front window ---")
        }
    }
    
}



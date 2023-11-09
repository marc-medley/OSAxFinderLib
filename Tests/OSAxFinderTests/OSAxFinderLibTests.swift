//
//  OSAxFinderLibTests.swift
//  OSAxFinder
//

import XCTest
@testable import OSAxFinderLib

class OSAxFinderLibTests: XCTestCase {
    
    func doSelectedFolderUrls() {
        let osaxFinder = OSAxFinder()
        let urlList = osaxFinder.selectedFolderUrls()
        
        let s = """
        ------------------------------------
        ------- SELECTED FOLDER URLS -------
        --- url list ---
        \(urlList)\n
        """
        print(s)
    }
    
    func doSelectedFileUrls() {
        let osaxFinder = OSAxFinder()
        let urlList = osaxFinder.selectedFileUrls()
        
        var s = """
        ------------------------------------
        -------- SELECTED FILE URLS --------
        --- url list ---
        \(urlList)\n
        """
        for url in urlList {
            s.append("\(url.absoluteString)\n")
        }
        print(s)
    }
    
    func dodirOfFrontWindow() {
        let osaxFinder = OSAxFinder()
        
        var s = """
        ----------------------------
        ------- FRONT WINDOW -------
        """
        if let urlList = osaxFinder.dirOfFrontWindow(printStdio: true) {
            s.append("--- url list ---\n\(urlList)\n")
        } else {
            s.append("--- no front window ---")
        }
        print(s)
    }
    
    func testSuite() {
        //doSelectedFolderUrls()
        //doSelectedFileUrls()
        //dodirOfFrontWindow()
        
        print("OSAxFinderLibTests testSuite() completed")
    }
    
}

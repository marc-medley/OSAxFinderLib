import Foundation

public final class OSAxFinder {
    ///  Supports library use by a command line tool
    private let arguments: [String]

    /// Supports library use by a command line tool
    public init(arguments: [String] = CommandLine.arguments) { 
        self.arguments = arguments
    }

    ///  Supports library use by a command line tool
    public func run() throws {
        print("Hello OSAxFinder. NYI as commandline tool.")
        let urls = selectedUrls()
        print(urls)
    }
    
    // MARK: - Focused Directory

    /// Fetch the `URL` of the first selected file
    /// - Returns: first selected file `URL`
    public func directoryFirstSelectedFile() -> URL? {
        let fileUrls = selectedFileUrls()
        if fileUrls.count > 0 {
            return fileUrls[0].deletingLastPathComponent()
        }
        return nil
    }
    
    /// Fetch the `URL` of the front Finder window. Returns nil if no window is open.
    /// - Returns: folder URL of the front window
    public func directoryFrontWindow() -> URL? {
        let result = runOsaScript(script: finderFrontWindowScript, removeTrailingNewline: true)
        let output = result.stdout
        if output.isEmpty == false {
            return URL(fileURLWithPath: output, isDirectory: true)
        }
        return nil
    }
    
    // MARK: - General Selections
    
    // :???:MYSTERY: returns /Debug/ URL when run in Xcode 
    // and no files are selected.

    /// Fetch the `URL` of the selected files and folders which have one of the specified extensions. The extensions are provide without a `.` dot. For example: `["jpg", "png"]`
    /// - Returns: (dirs: [URL], files: [URL]) tuple of folders and files
    public func selectedFileUrls(extensions: [String] = []) -> [URL] {
        let extensions = extensions.map { $0.lowercased() }
        var urlList = [URL]()
        let result = runOsaScript(script: finderSelectionScript, removeTrailingNewline: true)
        let pathList: [String] = result.stdout.components(separatedBy: "\n")
        for path in pathList {
            if path.hasSuffix("/") == false {
                let fileUrl = URL(fileURLWithPath: path, isDirectory: false)
                let fileExtension = fileUrl.pathExtension.lowercased()
                if extensions.isEmpty || extensions.contains(fileExtension) {
                    urlList.append(fileUrl)
                }
            }
        }
        return urlList
    }
    
    /// - Returns: all selected folders
    public func selectedFolderUrls() -> [URL] {
        var urlList = [URL]()
        let result = runOsaScript(script: finderSelectionScript, removeTrailingNewline: true)
        let pathList: [String] = result.stdout.components(separatedBy: "\n")
        for path in pathList {
            if path.hasSuffix("/") {
                urlList.append(URL(fileURLWithPath: path, isDirectory: true))
            }
        }
        return urlList
    }
    
    /// Fetch the `URL` of the selected files and folders which have one of the specified extensions. The extensions are provide without a `.` dot. For example: `["jpg", "png"]`
    /// - Returns: (dirs: [URL], files: [URL]) tuple of folders and files
    public func selectedUrls(extensions: [String] = []) -> (dirs: [URL], files: [URL]) {
        var urlDirsList = [URL]()
        var urlFilesList = [URL]()
        let result = runOsaScript(script: finderSelectionScript, removeTrailingNewline: true)
        let pathList: [String] = result.stdout.components(separatedBy: "\n")
        for path in pathList {
            if path.hasSuffix("/") == false {
                let fileUrl = URL(fileURLWithPath: path, isDirectory: false)
                let fileExtension = fileUrl.pathExtension
                if extensions.isEmpty || extensions.contains(fileExtension) {
                    urlFilesList.append(fileUrl)
                }
            } else { // `…dirname/`
                let pathDir = String(path.dropLast())
                if extensions.isEmpty == true {
                    let dirUrl = URL(fileURLWithPath: pathDir, isDirectory: true)
                    urlDirsList.append(dirUrl)
                } else {
                    for ext in extensions {
                        if pathDir.hasSuffix(".\(ext)"){
                            let dirUrl = URL(fileURLWithPath: pathDir, isDirectory: true)
                            urlDirsList.append(dirUrl)
                        }
                    }
                }
            }
        }
        return (urlDirsList, urlFilesList)
    }
    
    /// - Returns: all selected items
    public func selectedUrls() -> [URL] {
        var urlList = [URL]()
        let result = runOsaScript(script: finderSelectionScript, removeTrailingNewline: true)
        let pathList: [String] = result.stdout.components(separatedBy: "\n")
        for path in pathList {
            if path.hasSuffix("/") {
                urlList.append(URL(fileURLWithPath: path, isDirectory: true))
            }
            else {
                urlList.append(URL(fileURLWithPath: path, isDirectory: false))
            }
        }
        return urlList
    }

    // MARK: - Specialized Selections
    
    /// - Returns: , `*.gif`, `*.jpeg`, `*.jpg`, `*.png`, `*.tif`, `*.tiff` image files
    public func selectedImages() -> [URL] {
        return selectedFileUrls(extensions: ["png", "jpg", "jpeg", "tif", "tiff", "gif"])
    }
    
    /// - Returns: `*.html`, `*.htm` files
    public func selectedHtml() -> [URL] {
        return selectedFileUrls(extensions: ["html", "htm"])
    }
    
    /// - Returns: `*.md`, `*.markdown` files
    public func selectedMarkdown() -> [URL] {
        return selectedFileUrls(extensions: ["md", "markdown"])
    }

    /// - Returns: `*.pdf` files
    public func selectedPdf() -> [URL] {
        return selectedFileUrls(extensions: ["pdf"])
    }

    /// - Returns: `*.pdf` files in sorted order
    public func selectedPdfSorted() -> [URL] {
        var pdfList = selectedFileUrls(extensions: ["pdf"])
        // ascending sort order
        pdfList.sort(by: { $0.path < $1.path })
        return pdfList
    }
    
    // MARK: - Internal
    
    /// Method for running an AppleScript string.
    /// - Returns: `stdout` and `stderr` outputs when completed
    internal func runOsaScript(script: String, removeTrailingNewline: Bool = false, printStdio: Bool = false) -> (stdout: String, stderr: String) {
        var args = [String]()
        // flags: -s 
        //    h (default: human readable) | s (recompilable source) 
        //    e (default: errors to STDERR) | o (errors to STDOUT) 
        args.append(contentsOf: ["-e",script])
        // args after the script will be passed to the script
        
        //Process.launchedProcess(launchPath: "/usr/bin/osascript", arguments: args)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript", isDirectory: false)
        process.arguments = args
        
        let pipeOutput = Pipe()
        process.standardOutput = pipeOutput
        let pipeError = Pipe()
        process.standardError = pipeError
        do {
            try process.run()
            
            var stdoutStr = "" // do not mask foundation stdout
            var stderrStr = "" // do not mask foundation stderr
            
            let data = pipeOutput.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: String.Encoding.utf8) {
                if printStdio {
                    print("STANDARD OUTPUT\n" + output)
                }
                stdoutStr.append(output)
            }
            
            let dataError = pipeError.fileHandleForReading.readDataToEndOfFile()
            if let outputError = String(data: dataError, encoding: String.Encoding.utf8) {
                if printStdio {
                    print("STANDARD ERROR \n" + outputError)
                }
                stderrStr.append(outputError)
            }
            
            process.waitUntilExit()
            if printStdio {
                let status = process.terminationStatus
                print("STATUS: \(status)")
            }
            
            // osascript adds extra \n
            if removeTrailingNewline {
                stdoutStr = stdoutStr.replacingOccurrences(of: "\\n$", with: "", options: .regularExpression)
            }
            
            return (stdoutStr, stderrStr)
        } catch {
            let errorStr = "FAILED: \(error)"
            return ("", errorStr)
        }
    }
    
    /// AppleScript which returns a POSIX for the directory of the front Finder window.
    internal let finderFrontWindowScript = """
    on run
        tell application "Finder"
            set theWin to window 1
            set thePath to (POSIX path of (target of theWin as alias))
        end tell
        return thePath
    end run
    """
    
    /// AppleScript which returns a POSIX list of the currently selected Finder items.
    internal let finderSelectionScript = """
    on run
        tell application "Finder"
            set these_items to the selection as alias list
        end tell
        
        set posixList to {}
        repeat with i from 1 to the count of these_items
            set this_item to (item i of these_items) as alias

            -- --- log file information --- 
            -- set this_info to info for this_item
            -- log this_info
            
            -- file list
            set posixForm to (POSIX path of this_item)
            set end of posixList to (posixForm & "\n")
        end repeat
        return posixList as string
    end run
    """
}

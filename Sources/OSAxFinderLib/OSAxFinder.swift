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
    
    // MARK: - Enclosing Directory
    
    /// Fetch the `URL` of the first selected file
    /// - Returns: first selected file `URL`
    public func dirOfFirstSelectedFile() -> URL? {
        let fileUrls = selectedFileUrls()
        if fileUrls.count > 0 {
            return fileUrls[0].deletingLastPathComponent()
        }
        return nil
    }
    
    /// Fetch the `URL` of the front Finder window. Returns nil if no window is open.
    /// - Returns: folder URL of the front window
    public func dirOfFrontWindow(includeDesktop: Bool = false, printStdio: Bool = false) -> URL? {
        let result = runOsaScript(script: finderFrontWindowScript, removeTrailingNewline: true, printStdio: printStdio)
        let output = result.stdout
        if output.isEmpty == false {
            return URL(fileURLWithPath: output, isDirectory: true)
        }
        
        if includeDesktop {
            let fm = FileManager.default
            let desktopUrl = fm
                .homeDirectoryForCurrentUser
                .appending(component: "Desktop", directoryHint: .isDirectory)
            return desktopUrl
        } 
        return nil
    }
    
    // MARK: - General Selections
    
    /// Fetch the `URL` of the selected files filtered by extensions.
    /// The extension filter array is provide without a `.` dot. 
    /// For example: `["jpg", "png"]`
    /// 
    /// - Returns: [URL] file array
    public func selectedFileUrls(extensions: [String] = []) -> [URL] {
        let urlsSelected = selectedItemsUrls(files: true, folders: false)
        if urlsSelected.isEmpty { return [] }
        
        let extensions = extensions.map { $0.lowercased() }
        var urlsOut = [URL]()
        for fileUrl in urlsSelected {
            let fileExtension = fileUrl.pathExtension.lowercased()
            if extensions.isEmpty || extensions.contains(fileExtension) {
                urlsOut.append(fileUrl)
            }
        }
        return urlsOut
    }
    
    /// - Returns: selected folders with optional case insensitive `suffixes` filter
    public func selectedFolderUrls(
        suffixes: [String] = [],
        withAliasToDir: Bool = false, 
        onlyValid: Bool = true
    ) -> [URL] {
        let itemsSelected = selectedItemsList()
        if itemsSelected.isEmpty { return [] }
        
        let suffixList = suffixes.map { $0.lowercased() }
        var urlsOut = [URL]()
        for item in selectedItemsList() {
            if onlyValid { // skip invalid urls
                if item.isValid == false {
                    let path = item.url.path(percentEncoded: false)
                    print("Skipped invalid path \(path)")
                    continue
                }
            }
            
            if suffixList.isEmpty == false {
                var keep = false
                let name = item.url.lastPathComponent.lowercased()
                for suffix in suffixList {
                    if name.hasSuffix(suffix) {
                        keep = true
                        break
                    }
                }
                if keep == false { continue }
            }
            
            switch item.kind {
            case .alias:
                if withAliasToDir, item.isDirWhenResolved == true {
                    urlsOut.append(item.url)
                }
            case .folder:
                urlsOut.append(item.url)
            case .file:
                break
            case .link:
                break
            }
        }
        
        return urlsOut
    }
    
    /// Fetch selected files and folders `URL` with option name `endings` filtered.
    /// The extensions may be provideed without a `.` dot e.g., `["jpg", "png"]`
    /// Endings are case-insensitive.
    /// 
    /// - Returns: (dirs: [URL], files: [URL]) tuple of folders and files
    public func selectedUrls(endings: [String] = []) -> (dirs: [URL], files: [URL]) {
        let itemList = selectedItemsList()
        if itemList.isEmpty { return ([], []) }
        
        let endingsList = endings.map { $0.lowercased() }
        var urlDirsList = [URL]()
        var urlFilesList = [URL]()
        
        for item in itemList {
            let url = item.url
            let name = url.lastPathComponent.lowercased()
            for ending in endingsList {
                if name.hasSuffix(ending) {
                    if item.isDir {
                        urlDirsList.append(url)
                    } else if item.isFile {
                        urlFilesList.append(url)
                    }
                }
                break
            }
        }
        
        return (urlDirsList, urlFilesList)
    }
    
    /// - Returns: all valid selected alias files, files, folders. skips links.
    public func selectedUrls() -> [URL] {
        return selectedItemsUrls(files: true, folders: true, aliases: true)
    }
    
    // MARK: - JSON to URL Workflow
    
    /// Step 1. Fetch all selected items in JSON format
    /// - Returns: all selected items
    public func selectedItemsJson(printStdio: Bool = false) -> Data? {
        let result = runOsaScript(script: finderSelectedItemsScript, printStdio: printStdio)
        //print(result.stdout)
        return result.stdout.data(using: .utf8)
    }
    
    /// Step 2. Convert selected items in JSON format to `OSAxFinderItem`
    public func selectedItemsList() -> [OSAxFinderItem] {
        guard let json = selectedItemsJson() else {
            print("selectedItemsList() no json. why not some empty json?")
            return []
        }
        
        // ----- decode -----
        let decoder = JSONDecoder()
        guard let items = try? decoder.decode(OSAxFinderItemList.self, from: json) else {
            print("selectedItemsList() json decode failed:\n\(json)")
            return []
        }
        return items.osaxSelection
    }
    
    /// Step 3. Generated a filtered URL array.
    public func selectedItemsUrls(
        files: Bool, 
        folders: Bool, 
        aliases: Bool = false, 
        links: Bool = false, 
        onlyValid: Bool = true
    ) -> [URL] {
        var result = [URL]()
        for item in selectedItemsList() {
            if onlyValid { // skip invalid urls
                if item.isValid == false {
                    let path = item.url.path(percentEncoded: false)
                    print("Skipped invalid path \(path)")
                    continue
                }
            }
            
            switch item.kind {
            case .alias:
                if aliases { result.append(item.url) }
            case .folder:
                if folders { result.append(item.url) }
            case .file:
                if files { result.append(item.url) }
            case .link:
                if links { result.append(item.url) }
            }
        }
        
        return result
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
    
    internal let finderSelectedItemsScript = """
    on run
        tell application "Finder"
            -- selection (specifier) : the selection in the frontmost Finder window
            set select_items to the selection
            -- log select_items
            -- log "SELECT_ITEMS==" & select_items
        end tell
        
        set result_json to "{ \\"osaxSelection\\": ["
        
        repeat with i from 1 to the count of select_items
            set this_item to (item i of select_items)
            
            if i is greater than 1 then
                set result_json to result_json & ", "
            end if
            
            set item_kind to kind of this_item
            set item_str to this_item as string
            
            set result_json to result_json & "{\\"osaxKind\\":\\"" & item_kind
            set result_json to result_json & "\\", \\"osaxPath\\":\\"" & item_str
            set result_json to result_json & "\\"}"
        end repeat
        
        set result_json to result_json & "] }"
        return result_json
    end run
    """
}

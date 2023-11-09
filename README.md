# OSAxFinderLib

_The `OSAxFinderLib` Swift package provides both a library and a command line tool for fetching the URLs of the currently selected items in the macOS Finder._

Motivation: The current macOS Swift APIs (e.g. `FileManager` and `NSWorkspace`) do not provide access to the currently selected Finder URLs.

### Declaration 

``` swift
final class OSAxFinder
```
### Topics

_**Initializers**_

- `init(arguments: [String])`

    Supports library use by a command line tool

_**Command Line Tool Support**_

- `func run() throws`

    Supports library use by a command line tool

_**Instance Methods**_
 
_Enclosing Directory_

- `func dirOfFirstSelectedFile() -> URL?`

    Fetch the URL of the first selected file

- `func dirOfFrontWindow() -> URL?`

    Fetch the URL of the front Finder window. Returns nil if no window is open.

_General Selections_

- `func selectedFileUrls(extensions: [String]) -> [URL]`

    Fetch the URL of the selected files and folders which have one of the specified extensions. The extensions are provide without a . dot. For example: ["jpg", "png"]

- `func selectedFolderUrls(suffixes: [String], withAliasToDir: Bool, onlyValid: Bool) -> [URL]`

- `func selectedUrls(endings: [String]) -> (dirs: [URL], files: [URL])`

    Fetch the URL of the selected files and folders which have one of the specified extensions. The extensions are provide without a . dot. For example: `["jpg", "png"]`

- `func selectedUrls() -> [URL]`


_Specialized Selections_

- `func selectedHtml() -> [URL]`
- `func selectedImages() -> [URL]`
- `func selectedMarkdown() -> [URL]`
- `func selectedPdf() -> [URL]`
- `func selectedPdfSorted() -> [URL]`

_Workflow Methods_

- `func selectedItemsJson(printStdio: Bool = false) -> Data?`
    - Step 1. Fetch all selected items in JSON format
    - Returns: all selected items

- `func selectedItemsList() -> [OSAxFinderItem]`
    - Step 2. All selected items as `OSAxFinderItem`

- `func selectedItemsUrls(
        files: Bool, 
        folders: Bool, 
        aliases: Bool = false, 
        links: Bool = false, 
        validOnly: Bool = true
    ) -> [URL]`
    - Step 3. Selected and filtered URL array.

## Resources

See `man` pages for more information on `osascript`, `osacompile`, `osalang`.

# OSAxFinderLib

_The `OSAxFinderLib` Swift package which provides both a library and a command line tool for fetching the URLs of the currently selected items in the macOS Finder._

Motivation: The current macOS Swift APIs (e.g. `FileManager` and `NSWorkspace`) do not provide access to the currently selected Finder URLs.

### Declaration 

``` swift
final class OSAxFinder
```
### Topics

_**Initializers**_

* `init(arguments: [String])`

    Supports library use by a command line tool

_**Command Line Tool Support**_

* `func run() throws`

    Supports library use by a command line tool

_**Instance Methods**_

_Focused Directory_

* `func directoryFirstSelectedFile() -> URL?`

    Fetch the URL of the first selected file

* `func directoryFrontWindow() -> URL?`

    Fetch the URL of the front Finder window. Returns nil if no window is open.

_General Selections_

* `func selectedFileUrls(extensions: [String]) -> [URL]`

    Fetch the URL of the selected files and folders which have one of the specified extensions. The extensions are provide without a . dot. For example: ["jpg", "png"]

* `func selectedFolderUrls() -> [URL]`

* `func selectedUrls() -> [URL]`
* `func selectedUrls(extensions: [String]) -> (dirs: [URL], files: [URL])`

    Fetch the URL of the selected files and folders which have one of the specified extensions. The extensions are provide without a . dot. For example: `["jpg", "png"]`

_Specialized Selections_

* `func selectedHtml() -> [URL]`
* `func selectedImages() -> [URL]`
* `func selectedMarkdown() -> [URL]`
* `func selectedPdf() -> [URL]`
* `func selectedPdfSorted() -> [URL]`



## Resources

See `man` pages for more information on `osascript`, `osacompile`, `osalang`.

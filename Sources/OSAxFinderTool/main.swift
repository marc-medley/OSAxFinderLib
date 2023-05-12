import OSAxFinderLib

let tool = OSAxFinder()

do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}

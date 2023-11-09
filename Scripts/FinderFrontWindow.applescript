on run
    tell application "Finder"
        set theWin to window 1
        set thePath to (POSIX path of (target of theWin as alias))
    end tell
    return thePath
end run

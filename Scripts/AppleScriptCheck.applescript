-- NOTE: needs to be updated to the more recent scripts.

on run
    log "** checkbegin **"
    log "** finderSelection **"
    log finderSelection()
    log "** finderFrontWindow **"
    log finderFrontWindow()
end run

on finderFrontWindow()
    tell application "Finder"
        set theWin to window 1
        set thePath to (POSIX path of (target of theWin as alias))
    end tell
    return thePath
end finderFrontWindow

on finderSelection()
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
        set end of posixList to (posixForm & "
")
    end repeat
    return posixList as string
end finderSelection
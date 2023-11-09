on run
    tell application "Finder"
        -- selection (specifier) : the selection in the frontmost Finder window
        set select_items to the selection
        -- log select_items
        log "SELECT_ITEMS==" & select_items
    end tell
    
    repeat with i from 1 to the count of select_items
        set this_item to (item i of select_items)
        log "THIS_ITEM==" & this_item
        log "-¥-¥-¥-¥-"
        log this_item
        log "-¥-¥-¥-¥-"
        
        set item_kind to kind of this_item
        log "ITEM_KIND==" & item_kind
        
        -- set item_path to (this_item as path)
        -- log "ITEM_PATH==" & item_path
        
        -- `info for ITEM_ALIAS` returns an information record about a file or folder. 
        -- `ITEM_ALIAS` must be specified as an alias. e.g., `(ITEM as alias)`
        set this_alias to (this_item as alias)
        log "THIS_ALIAS==" & this_alias
        
        -- "info for"
        set this_info to info for (this_item as alias)
        -- log "THIS_INFO==" & this_info -- :FAIL: "Can't make {É} into type Unicode text"
        log " --THIS_INFO-- "
        log this_info
        log " --MORE_INFO-- "
        log "name==" & (name in this_info)
        log "displayed name==" & (displayed name in this_info)
        
        log "creation date==" & (creation date in this_info)
        log "modification date==" & (modification date in this_info)
        log "size==" & (size in this_info)
        log "folder==" & (folder in this_info)
        log "alias==" & (alias in this_info)
        log "package folder==" & (package folder in this_info)
        log "visible==" & (visible in this_info)
        log "extension hidden==" & (extension hidden in this_info)
        log "name extension==" & (name extension in this_info)
        log "displayed name==" & (displayed name in this_info)
        log "default application==" & (default application in this_info)
        log "name==" & (name in this_info)
        -- log "folder window==" & (folder window in this_info)
        
        log "file type==" & (file type in this_info)
        log "file creator==" & (file creator in this_info)
        
    end repeat
    
end run
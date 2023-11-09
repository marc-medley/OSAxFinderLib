on run
    tell application "Finder"
        -- selection (specifier) : the selection in the frontmost Finder window
        set select_items to the selection
        -- log select_items
        -- log "SELECT_ITEMS==" & select_items
    end tell
    
    set result_list to {}
    
    repeat with this_item in select_items
        set item_kind to kind of this_item
        
        -- Note: `ln -s É` links without original do not resolve and cause error
        -- set item_path to (POSIX path of (this_item as alias)) 
        
        -- Note: `as string` does not resolve the original `ln -s` link url
        set item_str to this_item as string
        copy ({item_kind, item_str}) to the end of the result_list
        
        log "STRING"
        log this_item as string
    end repeat
    
    return result_list
end run
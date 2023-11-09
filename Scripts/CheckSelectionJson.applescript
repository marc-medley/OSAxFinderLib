on run
    tell application "Finder"
        -- selection (specifier) : the selection in the frontmost Finder window
        set select_items to the selection
        -- log select_items
        -- log "SELECT_ITEMS==" & select_items
    end tell
    
    set result_json to "{ \"osaxSelection\": ["
    
    repeat with i from 1 to the count of select_items
        set this_item to (item i of select_items)
        
        if i is greater than 1 then
            set result_json to result_json & ", "
        end if
        
        set item_kind to kind of this_item
        
        -- Note: `ln -s É` links without original do not resolve and cause error
        -- set item_path to (POSIX path of (this_item as alias)) 
        
        -- Note: `as string` does not resolve to the `ln -s` link original url
        set item_str to this_item as string
        
        set result_json to result_json & "{\"osaxKind\":\"" & item_kind
        set result_json to result_json & "\", \"osaxPath\":\"" & item_str
        set result_json to result_json & "\"}"
    end repeat
    
    set result_json to result_json & "] }"
    return result_json
end run

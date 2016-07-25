#!/usr/bin/env ruby
# 2016-07-25
# inspired on
# http://www.red-sweater.com/AppleScript/
#
# Use:
#   On Terminal do:
#     selectinfinder.rb *pattern*
#   so a list of glob expanded item names in the directory is produced
#   This files are added to the selected ones in the top most window only when both
#   coincide (the window for the first arg and the selection window)

# Limitations:
#   It only only selects items in one directory/window, the path for the first one
#   Because of the way finder selection is handled (I thing) no directories can
#   be added


cwd = Dir.pwd
pattern = (ARGV.length>0)? ARGV : Dir.glob("*")

pattern.map! {|d|  (d =~ /^\//)? d : File.join(cwd,d.sub(/^\.\//, ""))}

thePathWindow = File.dirname(pattern[0])

%x{osascript -e '
    tell application "Finder"
    open the posix file "#{thePathWindow}"
    activate
    end tell'
}

alreadySelectedItems = %x{osascript -e '
    set selectedItems to {}
    tell application "Finder"
        set selectedItems to selection
    end tell
    set allPaths to {}
    repeat with bob in selectedItems
        set end of allPaths to POSIX path of (bob as alias)
    end repeat
    allPaths'
}

allItems = %x{osascript -e '
    set allItems to {}
    tell application "Finder"
        try
            set allItems to items of front window
        on error
            set allItems to items of desktop
        end try
    end tell
    set allPaths to {}
    repeat with bob in allItems
        set end of allPaths to POSIX path of (bob as alias)
    end repeat
    allPaths'
}


alreadySelectedItems = alreadySelectedItems.chomp.split(/, /)
allPaths = allItems.chomp.split(/, /)
allPaths = allPaths.select {|x| pattern.include? x}
allPaths += alreadySelectedItems
allPaths.map! {|x| %Q{posix file "#{x}"} }

allPathString = allPaths.join ", "

%x{osascript -e '
    tell application "Finder" to select { #{allPathString} }
    '
}


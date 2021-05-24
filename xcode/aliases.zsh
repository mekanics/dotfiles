### open Xcode shortcut
openx() {
    fileToOpen=''
    find . -maxdepth 2 -name "*.xcworkspace" -print0 | while IFS= read -r -d '' file; do
        fileToOpen=$file
    done

    if [ -n "$fileToOpen" ]; then
        echo "opening $fileToOpen"
        open $fileToOpen
    else
        find . -maxdepth 2 -name "*.xcodeproj" -print0 | while IFS= read -r -d '' file; do
            fileToOpen=$file
        done

        if [ -n "$fileToOpen" ]; then
            echo "opening $fileToOpen"
            open $fileToOpen
        else
            echo "No xcode files to open."
        fi
    fi
}

# Shorthand version of "openx", use "ox" instead.
alias ox=openx

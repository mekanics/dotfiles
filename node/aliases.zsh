### Publish & Push all yalc libraries

yalc_publish_push() {

    local root=${1:?}

    find $root -type d -name node_modules -prune -o -type d -name .next -prune -o -type f -name "package.json" -maxdepth 6 -mindepth 1 -print0 | while IFS= read -r -d '' file; do
        echo $file
        dir=$(dirname $file)

        yalc publish --push $dir

    done

}

# Shorthand version of "yalc_publish_push", use "ypp" instead.
alias ypp=yalc_publish_push

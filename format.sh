# $1 default format command to use
FORMAT_COMMAND_TO_RUN=${1:-"npm run format"}

echo '>> Formatting All Text-Based Files...'

echo """
# format.sh ###########################################################################################################
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/format.sh | bash -s --
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/format.sh | bash -s -- "npm run format"
=======================================================================================================================
FORMAT_COMMAND_TO_RUN: $FORMAT_COMMAND_TO_RUN
#######################################################################################################################
"""


# Configuration: Add folders or files you want to skip
EXCLUDE_DIRS=(
    ".git" 
    "node_modules" 
    "dist" 
    "build" 
    "vendor" 
    ".cache" 
    ".next" 
    "venv" 
    ".venv" 
    "target" # Common for Rust/Java
)

EXCLUDE_FILES=(
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    "*.min.js"
    "*.min.css"
    ".DS_Store"
)

# Build the directory prune arguments
dir_args=()
for i in "${!EXCLUDE_DIRS[@]}"; do
    dir_args+=("-name" "${EXCLUDE_DIRS[$i]}")
    if [ $i -lt $((${#EXCLUDE_DIRS[@]} - 1)) ]; then
        dir_args+=("-o")
    fi
done

# Build the file exclusion arguments
file_exclude_args=()
for i in "${!EXCLUDE_FILES[@]}"; do
    file_exclude_args+=("-name" "${EXCLUDE_FILES[$i]}")
    if [ $i -lt $((${#EXCLUDE_FILES[@]} - 1)) ]; then
        file_exclude_args+=("-o")
    fi
done

# find .
# 1. Prune the excluded directories
# 2. Filter out specific excluded files
# 3. Check MIME type for text files
find . -type d \( "${dir_args[@]}" \) -prune -o -type f ! \( "${file_exclude_args[@]}" \) -print | while read -r file; do
    if file --mime-type "$file" | grep -q "text/"; then
        echo "Formatting: $(readlink -f "$file")"
        
        # Removes trailing whitespace
        sed -i 's/[ \t]*$//' "$file"
    fi
done

echo '>> DONE Formatting All Text-Based Files'

echo '>> Formatting JS Scripts'
# We check if package.json exists before trying to run npm commands
if [ -f "package.json" ]; then
    eval "$FORMAT_COMMAND_TO_RUN"
else
    echo "Skipping $FORMAT_COMMAND_TO_RUN (No package.json found)"
fi
echo '>> DONE Formatting JS Scripts'

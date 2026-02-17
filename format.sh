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

# NOTE: refer to https://github.com/synle/bashrc/blob/master/.build/format for the latest
function format_cleanup {
  echo "🧹 Cleaning up junk files (*.Identifier, ._*)..."

  local base_dir="${1:-.}"

  if [ ! -d "$base_dir" ]; then
    echo "❌ Directory '$base_dir' not found."
    return 1
  fi

  local count=$(find "$base_dir" \
    -type f \( -name '*.Identifier' -o -name '._*' \) \
    -not -path '*/__pycache__/*' \
    -not -path '*/.cache/*' \
    -not -path '*/.ebextensions/*' \
    -not -path '*/.generated/*' \
    -not -path '*/.git/*' \
    -not -path '*/.gradle/*' \
    -not -path '*/.hg/*' \
    -not -path '*/.idea/*' \
    -not -path '*/.mypy_cache/*' \
    -not -path '*/.pytest_cache/*' \
    -not -path '*/.sass-cache/*' \
    -not -path '*/.svn/*' \
    -not -path '*/bower_components/*' \
    -not -path '*/build/*' \
    -not -path '*/coverage/*' \
    -not -path '*/CVS/*' \
    -not -path '*/dist/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/tmp/*' \
    -not -path '*/venv/*' \
    -not -path '*/webpack-dist/*' \
    -print | wc -l)

  if [ "$count" -gt 0 ]; then
    find "$base_dir" \
      -type f \( -name '*.Identifier' -o -name '._*' \) \
      -not -path '*/__pycache__/*' \
    -not -path '*/.cache/*' \
    -not -path '*/.ebextensions/*' \
    -not -path '*/.generated/*' \
    -not -path '*/.git/*' \
    -not -path '*/.gradle/*' \
    -not -path '*/.hg/*' \
    -not -path '*/.idea/*' \
    -not -path '*/.mypy_cache/*' \
    -not -path '*/.pytest_cache/*' \
    -not -path '*/.sass-cache/*' \
    -not -path '*/.svn/*' \
    -not -path '*/bower_components/*' \
    -not -path '*/build/*' \
    -not -path '*/coverage/*' \
    -not -path '*/CVS/*' \
    -not -path '*/dist/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/tmp/*' \
    -not -path '*/venv/*' \
    -not -path '*/webpack-dist/*' \
      -delete
    echo "✅ Removed $count junk files in: $base_dir"
  else
    echo "✨ No junk files found in: $base_dir"
  fi
}

function format_cleanup_light {
  local base_dir="${1:-.}"
  local max_depth=4

  if [ ! -d "$base_dir" ]; then
    return 1
  fi

  local count=$(find "$base_dir" \
    -maxdepth "$max_depth" \
    -type f \( -name '*.Identifier' -o -name '._*' \) \
    -not -path '*/__pycache__/*' \
    -not -path '*/.cache/*' \
    -not -path '*/.ebextensions/*' \
    -not -path '*/.generated/*' \
    -not -path '*/.git/*' \
    -not -path '*/.gradle/*' \
    -not -path '*/.hg/*' \
    -not -path '*/.idea/*' \
    -not -path '*/.mypy_cache/*' \
    -not -path '*/.pytest_cache/*' \
    -not -path '*/.sass-cache/*' \
    -not -path '*/.svn/*' \
    -not -path '*/bower_components/*' \
    -not -path '*/build/*' \
    -not -path '*/coverage/*' \
    -not -path '*/CVS/*' \
    -not -path '*/dist/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/tmp/*' \
    -not -path '*/venv/*' \
    -not -path '*/webpack-dist/*' \
    -print | wc -l)

  if [ "$count" -gt 0 ]; then
    find "$base_dir" \
      -maxdepth "$max_depth" \
      -type f \( -name '*.Identifier' -o -name '._*' \) \
      -not -path '*/__pycache__/*' \
    -not -path '*/.cache/*' \
    -not -path '*/.ebextensions/*' \
    -not -path '*/.generated/*' \
    -not -path '*/.git/*' \
    -not -path '*/.gradle/*' \
    -not -path '*/.hg/*' \
    -not -path '*/.idea/*' \
    -not -path '*/.mypy_cache/*' \
    -not -path '*/.pytest_cache/*' \
    -not -path '*/.sass-cache/*' \
    -not -path '*/.svn/*' \
    -not -path '*/bower_components/*' \
    -not -path '*/build/*' \
    -not -path '*/coverage/*' \
    -not -path '*/CVS/*' \
    -not -path '*/dist/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/tmp/*' \
    -not -path '*/venv/*' \
    -not -path '*/webpack-dist/*' \
      -delete
  fi
}

function format_other_text_based_files {
  echo '>> Formatting All Text-Based Files...'

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
}

############################################
format_cleanup
format_other_text_based_files

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

# NOTE: for the latest, refer to https://github.com/synle/bashrc/blob/master/.build/format 

# ----------------------------------------------------
# Light Cleanup (depth limited)
# ----------------------------------------------------
format_cleanup_light {
  local base_dir="${1:-.}"
  local max_depth=6

  if [ ! -d "$base_dir" ]; then
    return 1
  fi

  find "$base_dir" \
    -maxdepth "$max_depth" \
    \( \
      -type f \( \
        -name '._*' -o \
        -name '.AppleDouble' -o \
        -name '.DS_Store' -o \
        -name '.LSOverride' -o \
        -name '*.Identifier' -o \
        -name '*.orig' -o \
        -name '*.rej' -o \
        -name 'Desktop.ini' -o \
        -name 'ehthumbs.db' -o \
        -name 'Icon?' -o \
        -name 'Thumbs.db' \
      \) -o \
      -type d \( \
        -name '.Spotlight-V100' -o \
        -name '.Trashes' -o \
        -name '.fseventsd' -o \
        -name '__MACOSX' \
      \) \
    \) \
    -not -path '*/.cache/*' \
    -not -path '*/.ebextensions/*' \
    -not -path '*/.generated/*' \
    -not -path '*/.git/*' \
    -not -path '*/.gradle/*' \
    -not -path '*/.hg/*' \
    -not -path '*/.idea/*' \
    -not -path '*/.mypy_cache/*' \
    -not -path '*/.next/*' \
    -not -path '*/.pytest_cache/*' \
    -not -path '*/.sass-cache/*' \
    -not -path '*/.svn/*' \
    -not -path '*/.venv/*' \
    -not -path '*/CVS/*' \
    -not -path '*/__pycache*/*' \
    -not -path '*/__pycache__/*' \
    -not -path '*/bower_components/*' \
    -not -path '*/build/*' \
    -not -path '*/coverage/*' \
    -not -path '*/dist/*' \
    -not -path '*/env/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/target/*' \
    -not -path '*/tmp/*' \
    -not -path '*/vendor/*' \
    -not -path '*/venv/*' \
    -not -path '*/webpack-dist/*' \
    -exec rm -rf {} +
}

# ----------------------------------------------------
# Text File Formatting (trim trailing whitespace)
# ----------------------------------------------------
format_other_text_based_files {
  echo '>> Formatting text-based files...'

  EXCLUDE_DIRS=(
    ".cache"
    ".ebextensions"
    ".generated"
    ".git"
    ".gradle"
    ".hg"
    ".idea"
    ".mypy_cache"
    ".next"
    ".pytest_cache"
    ".sass-cache"
    ".svn"
    ".venv"
    "CVS"
    "__pycache*"
    "__pycache__"
    "bower_components"
    "build"
    "coverage"
    "dist"
    "env"
    "node_modules"
    "target"
    "tmp"
    "vendor"
    "venv"
    "webpack-dist"
  )

  EXCLUDE_FILES=(
    "*.Identifier"
    "*.min.css"
    "*.min.js"
    "*.orig"
    "*.rej"
    ".DS_Store"
    "package-lock.json"
    "pnpm-lock.yaml"
    "yarn.lock"
  )

  dir_args=()
  for i in "${!EXCLUDE_DIRS[@]}"; do
    dir_args+=("-name" "${EXCLUDE_DIRS[$i]}")
    [ $i -lt $((${#EXCLUDE_DIRS[@]} - 1)) ] && dir_args+=("-o")
  done

  file_exclude_args=()
  for i in "${!EXCLUDE_FILES[@]}"; do
    file_exclude_args+=("-name" "${EXCLUDE_FILES[$i]}")
    [ $i -lt $((${#EXCLUDE_FILES[@]} - 1)) ] && file_exclude_args+=("-o")
  done

  find . -type d \( "${dir_args[@]}" \) -prune -o     -type f ! \( "${file_exclude_args[@]}" \) -print |     while read -r file; do

      if file --mime-type "$file" | grep -q "text/"; then
        sed -i 's/[ \t]*$//' "$file"
      fi
    done

  echo '>> DONE Formatting All Text-Based Files'
}



############################################
format_cleanup_light
format_other_text_based_files

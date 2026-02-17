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
# ----------------------------------------------------
# Light Cleanup (depth limited)
# ----------------------------------------------------
function format_cleanup_light {

  local base_dir="${1:-.}"
  local max_depth=6

  if [ ! -d "$base_dir" ]; then
    return 1
  fi

  find "$base_dir" \
    -maxdepth "$max_depth" \
    \( \
      -type f \( \
        -name '*.Identifier' -o \
        -name '._*' -o \
        -name '.DS_Store' -o \
        -name '.AppleDouble' -o \
        -name '.LSOverride' -o \
        -name 'Icon?' \
      \) -o \
      -type d \( \
        -name '.Spotlight-V100' -o \
        -name '.Trashes' -o \
        -name '.fseventsd' \
      \) \
    \) \
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
    -exec rm -rf {} +
}


# ----------------------------------------------------
# Text File Formatting
# ----------------------------------------------------
function format_other_text_based_files {
  echo '>> Formatting text-based files...'

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
    "target"
  )

  EXCLUDE_FILES=(
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    "*.min.js"
    "*.min.css"
    ".DS_Store"
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

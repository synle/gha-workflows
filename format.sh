# $1 default format command to use
# $2 timeout in seconds (default 20)
FORMAT_COMMAND_TO_RUN=${1:-"npm run format"}
FORMAT_TIMEOUT=${2:-20}

# available format steps (whitelist)
AVAILABLE_FORMAT_STEPS=(
  "format_cleanup"
  "format_cleanup_light"
  "format_other_text_based_files"
  "format_python"
  "format_js"
)

# default format steps order
DEFAULT_FORMAT_STEPS=(
  "format_cleanup_light"
  "format_other_text_based_files"
  "format_python"
  "format_js"
)

# use passed-in steps (remaining args after $1 and $2) or fall back to defaults
shift 2 2>/dev/null || shift 2>/dev/null || true
if [ $# -gt 0 ]; then
  FORMAT_STEPS=("$@")
else
  FORMAT_STEPS=("${DEFAULT_FORMAT_STEPS[@]}")
fi

echo """
# format.sh ###########################################################################################################
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/format.sh | bash -s --
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/format.sh | bash -s -- "npm run format"
=======================================================================================================================
FORMAT_COMMAND_TO_RUN: $FORMAT_COMMAND_TO_RUN
FORMAT_TIMEOUT: $FORMAT_TIMEOUT
FORMAT_STEPS: ${FORMAT_STEPS[*]}
#######################################################################################################################
"""

# source the format functions from bashrc repo
source <(curl -s https://raw.githubusercontent.com/synle/bashrc/refs/heads/master/.build/format.sh)

# run formatting steps
for step in "${FORMAT_STEPS[@]}"; do
  # validate step is in the available list
  is_valid=false
  for available in "${AVAILABLE_FORMAT_STEPS[@]}"; do
    if [ "$step" = "$available" ]; then
      is_valid=true
      break
    fi
  done

  if [ "$is_valid" = false ]; then
    echo ">> Skipping unknown format step: $step"
    continue
  fi

  timeout $FORMAT_TIMEOUT bash -c "$step" || echo "$step failed or skipped."
done
echo "All formatting steps complete (some may have warnings)."

# run the custom format command
echo ">> Running custom format command: $FORMAT_COMMAND_TO_RUN"
timeout $FORMAT_TIMEOUT $FORMAT_COMMAND_TO_RUN
echo ">> Format completed successfully."

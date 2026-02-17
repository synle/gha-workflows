# $1: Files to watch
FILE_TO_WATCH=${1:-"*.json *.scss *.jsx *.js"}

# $2: Command to run
INITIAL_COMMAND_TO_RUN=${2:-"npm run start"}

echo """
# dev.sh #####################################################################################################################################
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/dev.sh | bash -s --
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/dev.sh | bash -s -- '*.json *.scss *.jsx *.js' 'npm run start'
==============================================================================================================================================
FILE_TO_WATCH: $FILE_TO_WATCH
INITIAL_COMMAND_TO_RUN:       $INITIAL_COMMAND_TO_RUN
##############################################################################################################################################
"""

get_file_state() {
  # Expand glob patterns properly
  stat -f "%m %z" $FILE_TO_WATCH 2>/dev/null | sort -r
}

# Initial setup and build
npm i
sh build.sh

# Start the initial command in the background (&)
# This prevents the script from blocking the watch loop
eval "$INITIAL_COMMAND_TO_RUN" > /dev/null 2>&1 &
APP_PID=$!

# Ensure the background process is killed when the script exits
trap "kill $APP_PID 2>/dev/null" EXIT

LAST_STATE=$(get_file_state)

while sleep 3; do
  CURRENT_STATE=$(get_file_state)

  if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
    echo "Change detected! Running build.sh..."
    sh build.sh
    LAST_STATE="$CURRENT_STATE"
  fi
done

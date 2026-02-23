FILE_TO_WATCH=${1:-"*.json *.scss *.jsx *.js"}
INITIAL_COMMAND_TO_RUN=${2:-"npm run start"}

echo """
# dev.sh #####################################################################
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/dev.sh | bash -s --
curl -s -- https://raw.githubusercontent.com/synle/gha-workflow/refs/heads/main/dev.sh | bash -s -- '*.json *.scss *.jsx *.js' 'npm run start'
==============================================================================
FILE_TO_WATCH:          $FILE_TO_WATCH
INITIAL_COMMAND_TO_RUN: $INITIAL_COMMAND_TO_RUN
##############################################################################
"""

get_file_state() {
  FIND_NAME_ARGS=""
  for pattern in $FILE_TO_WATCH; do
    [ -n "$FIND_NAME_ARGS" ] && FIND_NAME_ARGS="$FIND_NAME_ARGS -o"
    FIND_NAME_ARGS="$FIND_NAME_ARGS -name $pattern"
  done

  FIND_IGNORE_ARGS=""
  SEEN_PATHS=""
  for dir in "${IGNORED_PATHS[@]}"; do
    dir=$(echo "$dir" | xargs)
    [ -z "$dir" ] && continue
    echo "$SEEN_PATHS" | grep -qx "$dir" && continue
    SEEN_PATHS="$SEEN_PATHS
$dir"
    FIND_IGNORE_ARGS="$FIND_IGNORE_ARGS -not -path */${dir}/*"
  done

  find . $FIND_IGNORE_ARGS \
    -type f \( $FIND_NAME_ARGS \) \
    -exec $STAT_CMD {} \; 2>/dev/null | sort
}

IGNORED_PATHS=(
  "node_modules"
  ".git"
  "dist"
  "build"
  ".next"
  ".cache"
  "venv"
  ".venv"
  "target"
)

if stat -c "%Y %n" /dev/null > /dev/null 2>&1; then
  STAT_CMD="stat -c %Y_%n"
else
  STAT_CMD="stat -f %m_%N"
fi

npm i
sh build.sh

eval "$INITIAL_COMMAND_TO_RUN" > /dev/null 2>&1 &
APP_PID=$!

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

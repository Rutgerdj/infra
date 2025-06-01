#!/bin/sh
#
# Pre-commit hook that verifies if all files names 'secrets.yaml'
# are encrypted.
# If not, commit will fail with an error message
#

FILES_PATTERN='.*secrets.ya?ml$'

EXIT_STATUS=0
wipe="\033[1m\033[0m"
yellow='\033[1;33m'
# carriage return hack. Leave it on 2 lines.
cr='
'

for f in $(git diff --cached --name-only | grep -E $FILES_PATTERN)
do
  sops --config nixos/.sops.yaml -e $f >> /dev/null
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    EXIT_STATUS=1
    UNENCRYPTED_FILES="${UNENCRYPTED_FILES}${cr}${f}"
  fi

done

if [ ! $EXIT_STATUS = 0 ] ; then
  echo '# COMMIT REJECTED'
  echo '# Looks like unencrypted sops files are part of the commit:'
  echo '#'
  while read -r line; do
    if [ -n "$line" ]; then
      echo -e "#\t${yellow}unencrypted:   $line${wipe}"
    fi
  done <<< "$UNENCRYPTED_FILES"
  echo '#'
  exit $EXIT_STATUS
fi
exit $EXIT_STATUS
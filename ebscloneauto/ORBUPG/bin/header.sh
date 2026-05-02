title()
{
  echo
  echo
  ch="$(printf "%80s" "")"
  printf "%s\n" "${ch// /#}"
  echo $(date)
  echo "${TITLE}"
  echo "${1}"
  printf "%s\n" "${ch// /#}"
}

. $(dirname $(readlink -f $0))/run.env

BEFORE="$(date +%s)"

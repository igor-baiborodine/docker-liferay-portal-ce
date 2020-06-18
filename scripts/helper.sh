function replace_field() {
  local target_file="$1"
  local field="$2"
  local content="$3"

  local extra_sed="${4:-}"
  local sed_escaped_value
  sed_escaped_value="$(echo "$content" | sed 's/[\/&]/\\&/g')"
  sed_escaped_value="${sed_escaped_value//$'\n'/\\n}"
  sed -ri -e "s/${extra_sed}%%${field}%%${extra_sed}/$sed_escaped_value/g" "$target_file"
}

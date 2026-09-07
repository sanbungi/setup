#!/bin/bash

preflight_requested() {
  [ "${1:-}" = "--check" ]
}

preflight_package_manager() {
  if command -v apt >/dev/null 2>&1; then
    echo "[Check] package manager: apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "[Check] package manager: dnf"
  else
    echo "[Error] apt or dnf was not found." >&2
    return 1
  fi
}

preflight_commands() {
  local command_name
  for command_name in "$@"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      echo "[Error] required command was not found: $command_name" >&2
      return 1
    fi
  done
}

preflight_http() {
  local url="$1"
  preflight_commands curl
  echo "[Check] URL: $url"
  curl --fail --silent --show-error --location --range 0-0 --output /dev/null "$url"
}

preflight_git() {
  local url="$1"
  local ref="${2:-HEAD}"
  preflight_commands git
  echo "[Check] Git: $url ($ref)"
  git ls-remote --exit-code "$url" "$ref" >/dev/null
}

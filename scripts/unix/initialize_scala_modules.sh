#!/usr/bin/env bash

initialize_scala_modules() {
  # 🎨 Colors
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[1;34m'
  CYAN='\033[0;36m'
  RESET='\033[0m'

  local confirm=false
  local what_if=false
  local verbose=false

  # 🔧 Defaults
  local base_package=("com" "github" "username")
  local app_package=("")
  local lib_package=("")
  local app_file_name="App.scala"
  local lib_file_name="Lib.scala"

  # 🧾 Argument parser
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat <<'EOF'
initialize_scala_modules - Scaffolds a modular Scala project with `app` and `lib` components.

This function creates a nested folder structure for a Scala project with separate `app` and `lib`
directories, following the typical convention `src/main/scala/<package>/...`. It optionally supports:
- interactive confirmation (`--confirm`)
- dry-run simulation (`--what-if`)
- verbose output (`--verbose`)

The function is fully configurable with custom base packages, module names, and filenames.

USAGE:
  initialize_scala_modules [OPTIONS]

OPTIONS:
  --confirm                   Ask for confirmation before each directory or file is created.
  --what-if                   Display what actions would be taken without executing them.
  --verbose                   Enable detailed logging.
  --base-package <parts>...   Base namespace for both app and lib (e.g. com github username).
  --app-package <parts>...    Subpackage path for the app module (default: app).
  --lib-package <parts>...    Subpackage path for the lib module (default: lib).
  --app-file-name <file>      Scala filename for the app module (default: App.scala).
  --lib-file-name <file>      Scala filename for the lib module (default: Lib.scala).
  -h, --help                  Show this help message and exit.

EXAMPLES:
  initialize_scala_modules
      Creates:
        app/src/main/scala/com/github/username/app/App.scala
        lib/src/main/scala/com/github/username/lib/Lib.scala

  initialize_scala_modules --what-if --verbose
      Simulates the creation and prints the planned file structure.

  initialize_scala_modules --base-package org example --app-file-name Main.scala
      Uses custom base package and creates a main file named Main.scala.

NOTES:
- Uses `mkdir -p` and `touch` under the hood for safe file/directory creation.
- Designed to be reusable in larger scaffolding scripts for educational or real-world projects.
EOF
        return 0
        ;;
      --confirm) confirm=true ;;
      --what-if) what_if=true ;;
      --verbose) verbose=true ;;
      --base-package)
        shift; base_package=()
        while [[ $# -gt 0 && "$1" != --* ]]; do base_package+=("$1"); shift; done; continue ;;
      --app-package)
        shift; app_package=()
        while [[ $# -gt 0 && "$1" != --* ]]; do app_package+=("$1"); shift; done; continue ;;
      --lib-package)
        shift; lib_package=()
        while [[ $# -gt 0 && "$1" != --* ]]; do lib_package+=("$1"); shift; done; continue ;;
      --app-file-name) shift; app_file_name="$1" ;;
      --lib-file-name) shift; lib_file_name="$1" ;;
      *) echo "⚠️ Unknown option: $1" >&2; return 1 ;;
    esac
    shift
  done

  # 🔧 Helpers
  get_package_path() {
    local IFS="/"
    echo "$*"
  }

  create_scala_item() {
    local action="$1"         # e.g., mkdir or touch
    local action_arg="$2"     # e.g., -p or empty
    local file_path="$3"
    local label="$4"
    local emoji="$5"
    local name="${6:-$file_path}"

    $verbose && echo -e "${BLUE}${emoji} Creating $label: $name${RESET}"

    if $what_if; then
      echo -e "${YELLOW}🔍 WhatIf: $action${action_arg:+ $action_arg} '$file_path'${RESET}"
      return
    fi

    if $confirm; then
      echo -ne "${CYAN}Create $label '$file_path'? [y/N] ${RESET}"
      read -r reply
      [[ "$reply" =~ ^[Yy]$ ]] || return
    fi

    if [[ -n "$action_arg" ]]; then
      "$action" "$action_arg" "$file_path"
    else
      "$action" "$file_path"
    fi
  }

  new_scala_directory() {
    create_scala_item "mkdir" "-p" "$1" "directory" "📁"
  }

  new_scala_file() {
    create_scala_item "touch" "" "$1" "file" "📄" "$2"
  }

  # 🧱 Paths
  local scala_path
  scala_path=$(get_package_path "src" "main" "scala" "${base_package[@]}")

  local app_path
  app_path="app/$scala_path/$(get_package_path "${app_package[@]}")"
  local lib_path
  lib_path="lib/$scala_path/$(get_package_path "${lib_package[@]}")"

  local app_file="$app_path/$app_file_name"
  local lib_file="$lib_path/$lib_file_name"

  $verbose && {
    echo -e "${GREEN}📦 App: $app_file${RESET}"
    echo -e "${GREEN}📦 Lib: $lib_file${RESET}"
  }

  new_scala_directory "$app_path" "app"
  new_scala_directory "$lib_path" "lib"
  new_scala_file "$app_file" "$app_file_name"
  new_scala_file "$lib_file" "$lib_file_name"
}

#!/usr/bin/env bash
set -euo pipefail

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;36m"
GRAY="\033[1;30m"
WHITE_ON_RED="\033[1;41m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_INSTALL_SCRIPTS_DIR="${SCRIPT_DIR}/tool-install-scripts"


# Helper to run a command and print success/error output.
run_command() {
    local use_sudo="${1}"
    shift
    local cmd=("$@")

    if [[ "${use_sudo}" == "true" ]]; then
        cmd=("sudo" "${cmd[@]}")
    fi

    local output
    if output=$("${cmd[@]}" 2>&1); then
        echo -e "${GREEN}Success${NC}: ${output}"
    else
        echo -e "${RED}Error${NC}: ${output}"
    fi
}


# Prompt the user with a question and a set of valid single-character options.
# Blank input returns the default. Loops until valid input is given.
#
# Usage: get_input <prompt> <options e.g. "c/o"> <default>
# Returns: sets global GET_INPUT_RESULT
get_input() {
    local prompt="${1}"
    local options="${2}"
    local default="${3}"

    # Build a list of valid single chars from the options string (strip '/')
    local valid_chars="${options//\//}"

    while true; do
        read -rp $"${prompt}\n(${options} [default=${default}]): " user_input
        user_input="${user_input,,}"  # lowercase

        # Blank input → use default
        if [[ -z "${user_input}" ]]; then
            GET_INPUT_RESULT="${default}"
            return
        fi

        # Single char that exists in valid_chars
        if [[ "${#user_input}" -eq 1 && "${valid_chars}" == *"${user_input}"* ]]; then
            GET_INPUT_RESULT="${user_input}"
            return
        fi

        echo -e "${RED}Invalid input. Please enter one of: ${options}.${NC}"
    done
}


run_core_set() {
    echo "Running core set tool install scripts..."
    local core_set_dir="${TOOL_INSTALL_SCRIPTS_DIR}/core-set"

    if [[ ! -d "${core_set_dir}" ]]; then
        echo -e "${RED}Error${NC}: Core set directory not found: ${core_set_dir}"
        return 1
    fi

    local scripts=("${core_set_dir}"/*.sh)
    if [[ ! -e "${scripts[0]}" ]]; then
        echo "No scripts found in ${core_set_dir}."
        return 0
    fi

    for script in "${scripts[@]}"; do
        run_command "false" "bash" "${script}"
    done
}


run_optionals() {
    local optionals_dir="${TOOL_INSTALL_SCRIPTS_DIR}/optionals"

    if [[ ! -d "${optionals_dir}" ]]; then
        echo -e "${RED}Error${NC}: Optionals directory not found: ${optionals_dir}"
        return 1
    fi

    # Build array of optional scripts
    local optionals=("${optionals_dir}"/*.sh)
    if [[ ! -e "${optionals[0]}" ]]; then
        echo "No optional scripts found in ${optionals_dir}."
        return 0
    fi

    while true; do
        echo "Available optionals:"
        for i in "${!optionals[@]}"; do
            echo "  $((i + 1)). $(basename "${optionals[$i]}")"
        done
        echo

        local choice
        while true; do
            read -rp "Choose program to install (number): " choice

            # Must be an integer
            if ! [[ "${choice}" =~ ^[0-9]+$ ]]; then
                echo "Invalid input. Please enter a number."
                continue
            fi

            if (( choice < 1 || choice > ${#optionals[@]} )); then
                echo "Invalid input. Please enter a number between 1 and ${#optionals[@]}."
                continue
            fi

            break
        done

        # Arrays are 0-indexed; user entered 1-indexed
        run_command "false" "bash" "${optionals[$((choice - 1))]}"

        get_input "Run again? (y/N)" "y/n" "n"
        if [[ "${GET_INPUT_RESULT}" != "y" ]]; then
            break
        fi
    done
}


main() {
    echo "Tool install scripts program."

    get_input "Core set, or Optionals?" "c/o" "c"
    local tools_choice="${GET_INPUT_RESULT}"

    if [[ "${tools_choice}" == "c" ]]; then
        run_core_set
    elif [[ "${tools_choice}" == "o" ]]; then
        run_optionals
    fi
}


trap 'echo -e "\n${YELLOW}Interrupted by user${NC}"; exit 0' INT

main "$@"
from __future__ import annotations
from typing import Sequence
import subprocess
import sys
from pathlib import Path


# ANSI color codes
class Color:
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;36m"
    GRAY = "\033[1;30m"
    WHITE_ON_RED = "\033[1;41m"
    NC = "\033[0m"  # No Color


SCRIPT_DIR: Path = Path(__file__).parent.resolve()
TOOL_INSTALL_SCRIPTS_DIR = Path(SCRIPT_DIR / "tool-install-scripts")


def get_input(prompt: str, options: str, default: str) -> str:
    """
    Helper to handle interactive prompts with validation.
    - If user enters an invalid option, they will be prompted again.
    - If user enters a blank option, the default will be returned.

    Separate the options with a "/" delimiter.
    """

    while True:
        try:
            user_input: str = (
                input(
                    f"{prompt}\n({options} [default={default}]): "
                )
                .lower()
                .strip()
            )
            if not user_input:
                return default
            # Check if input matches any character in the options string (ignoring separators)
            valid_chars: str = options.lower().replace("/", "")
            if user_input in valid_chars and len(user_input) == 1:
                return user_input
            print(
                f"{Color.RED}Invalid input. Please enter one of: {options}.{Color.NC}"
            )
        except EOFError:
            return default


def run_command(cmd: Sequence[str], use_sudo: bool = False) -> None:
    """Runs a shell command or simulates it if self.dry_run is True."""

    full_cmd: list[str] = (["sudo"] + list(cmd)) if use_sudo else list(cmd)
    cmd_str: str = " ".join(full_cmd)

    try:
        result: subprocess.CompletedProcess[str] = subprocess.run(
            full_cmd, capture_output=True, text=True, check=False
        )
        # return result.returncode == 0, result.stdout + result.stderr
    except Exception as e:
        print(f"{Color.RED}Error{Color.NC}: {e}")
    else:
        print(f"{Color.GREEN}Success{Color.NC}: {result.stdout + result.stderr}")


def main() -> None:
    """Run tool install scripts"""
    
    print("Tool install scripts program.")
    tools_choice: str = get_input(
        "Core set, or Optionals?", "c/o", "c"
    )
    if tools_choice == "c":
        print("Running core set tool install scripts...")
        core_set_dir = TOOL_INSTALL_SCRIPTS_DIR / "core-set"
        for script in core_set_dir.glob("*.sh"):
            # we dont need to use sudo here, if any of the scripts require
            # it then it will be in the script.
            run_command(["bash", str(script)], use_sudo=False)

    elif tools_choice == "o":
        optionals_dir = TOOL_INSTALL_SCRIPTS_DIR / "optionals"
        optionals_list: list[Path] = list(optionals_dir.glob("*.sh"))

        while True:

            print("Available optionals:")
            for i, script in enumerate(optionals_list):
                print(f"  {i+1}. {script.name}")
            print()
            while True:
                optional_choice = input("Choose program to install (number): ")
                try:
                    optional_choice = int(optional_choice)
                except ValueError:
                    print("Invalid input. Please enter a number.")
                    continue
                if optional_choice <= 0 or optional_choice > len(optionals_list):
                    print("Invalid input. Please enter a number between 1 and", len(optionals_list))
                    continue
                break
            # we added 1 to the index so we need to subtract 1 here
            run_command(["bash", str(optionals_list[optional_choice-1])], use_sudo=False)

            run_again: str = get_input(
                "Run again? (y/N) ", "y/n", "n"
            )
            if run_again == "y":
                continue
            else:
                break
    


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Color.YELLOW}Interrupted by user{Color.NC}")
        sys.exit(0)
    except Exception as e:
        print(f"{Color.RED}Error: {e}{Color.NC}", file=sys.stderr)
        sys.exit(1)

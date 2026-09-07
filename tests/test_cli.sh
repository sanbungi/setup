#!/bin/bash
set -euo pipefail

TOOL="${1:-./setup_tool}"
TOOL="$(cd "$(dirname "$TOOL")" && pwd)/$(basename "$TOOL")"
EXPECTED_IDS=$'neovim\nscreen\nnodejs\nruby\ngolang\ndlang\nrust\ndocker\ntmux\natcoder\nconfig'

actual_ids="$($TOOL --list | cut -f1)"
if [ "$actual_ids" != "$EXPECTED_IDS" ]; then
  echo "Task ID list does not match the expected public interface." >&2
  exit 1
fi

TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT
SOURCE_DIR="$TEST_ROOT/source"
TEST_HOME="$TEST_ROOT/home"
RUN_LOG="$TEST_ROOT/run.log"
mkdir -p "$SOURCE_DIR" "$TEST_HOME"

scripts=(
  build_nvim_lts.sh build_screen.sh install_nodejs.sh install_ruby.sh
  install_golang.sh install_dlang.sh install_rust.sh install_docker.sh
  install_tmux.sh install_atcoder_tools.sh copy_setting.sh
)
for script in "${scripts[@]}"; do
  sed "s|SCRIPT_NAME|$script|g" > "$SOURCE_DIR/$script" <<'EOF'
#!/bin/bash
echo SCRIPT_NAME >> "$RUN_LOG"
if [ "${FAIL_TASK:-}" = "SCRIPT_NAME" ]; then
  exit 1
fi
EOF
done

run_tool() {
  HOME="$TEST_HOME" RUN_LOG="$RUN_LOG" "$TOOL" --check --source-dir "$SOURCE_DIR" "$@"
}

: > "$RUN_LOG"
run_tool --task tmux >/dev/null
[ "$(cat "$RUN_LOG")" = "install_tmux.sh" ]

: > "$RUN_LOG"
run_tool --task tmux --task tmux >/dev/null
[ "$(wc -l < "$RUN_LOG")" -eq 1 ]

: > "$RUN_LOG"
run_tool --task atcoder >/dev/null
expected_dependency_order=$'install_nodejs.sh\ninstall_atcoder_tools.sh'
[ "$(cat "$RUN_LOG")" = "$expected_dependency_order" ]

: > "$RUN_LOG"
run_tool --all >/dev/null
[ "$(wc -l < "$RUN_LOG")" -eq 11 ]

set +e
HOME="$TEST_HOME" RUN_LOG="$RUN_LOG" FAIL_TASK=install_golang.sh \
  "$TOOL" --check --source-dir "$SOURCE_DIR" --task golang >/dev/null 2>&1
failure_status=$?
"$TOOL" --task unknown >/dev/null 2>&1
unknown_status=$?
"$TOOL" --check >/dev/null 2>&1
missing_selection_status=$?
"$TOOL" --check --task tmux --source-dir "$TEST_ROOT/missing" >/dev/null 2>&1
missing_source_status=$?
set -e

[ "$failure_status" -eq 1 ]
[ "$unknown_status" -eq 2 ]
[ "$missing_selection_status" -eq 2 ]
[ "$missing_source_status" -eq 2 ]

if find "$TEST_HOME" -mindepth 1 -print -quit | grep -q .; then
  echo "Check mode modified HOME." >&2
  exit 1
fi

# Regression: running from $HOME/setup must never remove the current directory.
REPOSITORY_FIXTURE="$TEST_ROOT/repository"
mkdir -p "$REPOSITORY_FIXTURE"
cp "$SOURCE_DIR/install_tmux.sh" "$REPOSITORY_FIXTURE/install_tmux.sh"
git -C "$REPOSITORY_FIXTURE" init -q
git -C "$REPOSITORY_FIXTURE" add install_tmux.sh
git -C "$REPOSITORY_FIXTURE" -c user.name=test -c user.email=test@example.com commit -qm fixture
mkdir -p "$TEST_HOME/setup"
touch "$TEST_HOME/setup/must-survive"
(
  cd "$TEST_HOME/setup"
  HOME="$TEST_HOME" RUN_LOG="$RUN_LOG" SETUP_REPOSITORY_URL="$REPOSITORY_FIXTURE" \
    "$TOOL" --task tmux >/dev/null
)
test -f "$TEST_HOME/setup/must-survive"

echo "CLI tests passed."

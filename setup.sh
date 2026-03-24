#!/bin/bash
set -e

# ─── Color Setup ─────────────────────────────────────────────────────────────

setup_colors() {
  if [[ -n "$NO_COLOR" ]] || [[ ! -t 1 ]]; then
    RED="" GREEN="" YELLOW="" CYAN="" MAGENTA="" BOLD="" DIM="" RESET="" UL=""
    return
  fi

  RED='\033[31m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  CYAN='\033[36m'
  MAGENTA='\033[35m'
  BOLD='\033[1m'
  DIM='\033[2m'
  RESET='\033[0m'
  UL='\033[4m'
}

# Compute a gradient color from pink (255,100,200) to cyan (0,220,255)
gradient_color() {
  local line=$1 total=$2
  if [[ -n "$NO_COLOR" ]] || [[ -z "$BOLD" ]]; then
    return
  fi
  local max=$((total - 1))
  if [[ $max -le 0 ]]; then max=1; fi
  local r=255
  local g=$((140 + 90 * line / max))
  local b=$((20 + 60 * line / max))
  printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

# ─── Utilities ────────────────────────────────────────────────────────────────

print_blank() { echo ""; }

print_line() {
  echo -e "  $*${RESET}"
}

print_step() {
  local icon="$1" color="$2"
  shift 2
  echo -e "  ${color}${icon}${RESET}  $*${RESET}"
}

print_success() { print_step "✓" "$GREEN" "$@"; }
print_fail()    { print_step "✗" "$RED" "$@"; }
print_warn()    { print_step "⚠" "$YELLOW" "$@"; }
print_info()    { print_step "›" "$CYAN" "$@"; }

display_path() {
  echo "${1/#$HOME/~}"
}

# ─── ASCII Art Header ────────────────────────────────────────────────────────

print_header() {
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)

  # Skip art if terminal is too narrow
  if [[ $cols -lt 55 ]]; then
    print_blank
    echo -e "  ${BOLD}Second Brain${RESET}"
    echo -e "  ${DIM}Obsidian + Claude Code${RESET}"
    print_blank
    return
  fi

  local art=(
    "  ███████ ███████  ██████  ██████  ███    ██ ██████  "
    "  ██      ██      ██      ██    ██ ████   ██ ██   ██ "
    "  ███████ █████   ██      ██    ██ ██ ██  ██ ██   ██ "
    "       ██ ██      ██      ██    ██ ██  ██ ██ ██   ██ "
    "  ███████ ███████  ██████  ██████  ██   ████ ██████  "
    "                                                     "
    "  ██████  ██████   █████  ██ ███    ██                "
    "  ██   ██ ██   ██ ██   ██ ██ ████   ██                "
    "  ██████  ██████  ███████ ██ ██ ██  ██                "
    "  ██   ██ ██   ██ ██   ██ ██ ██  ██ ██                "
    "  ██████  ██   ██ ██   ██ ██ ██   ████                "
  )

  local total=${#art[@]}
  print_blank
  for i in "${!art[@]}"; do
    local color
    color=$(gradient_color "$i" "$total")
    echo -e "${color}${art[$i]}${RESET}"
  done
  echo -e "  ${DIM}Obsidian + Claude Code personal knowledge OS${RESET}"
  echo -e "  ${DIM}by Ruy Ramos · ruy.se${RESET}"
  print_blank
}

# ─── Prerequisite Checks ─────────────────────────────────────────────────────

check_obsidian() {
  # macOS: use Spotlight
  if [[ "$(uname)" == "Darwin" ]]; then
    if mdfind "kMDItemCFBundleIdentifier == 'md.obsidian'" 2>/dev/null | grep -q .; then
      return 0
    fi
    [[ -d "/Applications/Obsidian.app" ]] && return 0
    return 1
  fi
  # Linux: check common locations
  command -v obsidian &>/dev/null && return 0
  [[ -f "/usr/bin/obsidian" ]] && return 0
  return 1
}

check_claude_code() {
  command -v claude &>/dev/null
}

check_obsidian_skills() {
  command -v obsidian &>/dev/null
}

check_prerequisites() {
  local required_missing=0

  echo -e "  ${BOLD}Prerequisites${RESET}"
  print_blank

  # Obsidian
  if check_obsidian; then
    print_success "Obsidian              ${DIM}installed${RESET}"
  else
    print_fail "Obsidian              ${DIM}not found${RESET}"
    echo -e "     ${DIM}└─ Install from ${UL}https://obsidian.md${RESET}${DIM} (free)${RESET}"
    required_missing=$((required_missing + 1))
  fi

  # Claude Code
  if check_claude_code; then
    print_success "Claude Code           ${DIM}installed${RESET}"
  else
    print_fail "Claude Code           ${DIM}not found${RESET}"
    echo -e "     ${DIM}└─ Install: ${CYAN}npm install -g @anthropic-ai/claude-code${RESET}"
    required_missing=$((required_missing + 1))
  fi

  # obsidian-skills (optional)
  if check_obsidian_skills; then
    print_success "obsidian-skills       ${DIM}installed${RESET}"
  else
    print_warn "obsidian-skills       ${DIM}not found (install after setup)${RESET}"
    echo -e "     ${DIM}└─ Run: ${CYAN}claude install obsidian-skills${RESET}"
  fi

  print_blank

  if [[ $required_missing -gt 0 ]]; then
    echo -e "  ${YELLOW}${required_missing} required tool(s) missing.${RESET}"
    echo -e "  ${DIM}You can still run setup — install them before using the commands.${RESET}"
    print_blank
    echo -ne "  Continue anyway? ${DIM}(y/N)${RESET} "
    read -r -n 1 reply
    echo ""
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      print_blank
      echo -e "  ${DIM}Setup cancelled.${RESET}"
      print_blank
      exit 0
    fi
    print_blank
  fi
}

# ─── Interactive Prompts ─────────────────────────────────────────────────────

prompt_vault_name() {
  echo -e "  ${BOLD}Vault Configuration${RESET}"
  print_blank

  while true; do
    echo -e "  ${DIM}Vault name — this becomes your Obsidian vault name${RESET}"
    echo -ne "  ${CYAN}▸${RESET} "
    read -r VAULT_NAME
    if [[ -n "$VAULT_NAME" ]]; then
      break
    fi
    echo -e "  ${RED}Vault name cannot be empty${RESET}"
    print_blank
  done
}

prompt_vault_path() {
  local default_path="~/Documents/projects/$VAULT_NAME"

  print_blank
  echo -e "  ${DIM}Vault path${RESET}"
  echo -e "  ${DIM}default: ${default_path}${RESET}"
  echo -ne "  ${CYAN}▸${RESET} "
  read -r input_path
  print_blank

  if [[ -z "$input_path" ]]; then
    VAULT_PATH="$HOME/Documents/projects/$VAULT_NAME"
  else
    VAULT_PATH="${input_path/#\~/$HOME}"
  fi
}

confirm_setup() {
  local display_vault_path
  display_vault_path=$(display_path "$VAULT_PATH")

  echo -e "  ${DIM}───────────────────────────────────────${RESET}"
  print_blank
  echo -e "  ${BOLD}Confirm${RESET}"
  print_blank
  echo -e "  Vault name   ${BOLD}$VAULT_NAME${RESET}"
  echo -e "  Vault path   ${BOLD}${display_vault_path}${RESET}"
  echo -e "  Commands     ${DIM}10 commands → ~/.claude/commands/${RESET}"
  print_blank

  echo -ne "  Proceed? ${DIM}(Y/n)${RESET} "
  read -r -n 1 reply
  echo ""
  if [[ "$reply" =~ ^[Nn]$ ]]; then
    print_blank
    echo -e "  ${DIM}Setup cancelled.${RESET}"
    print_blank
    exit 0
  fi
  print_blank
}

# ─── Installation ─────────────────────────────────────────────────────────────

create_vault() {
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  local display_vault_path
  display_vault_path=$(display_path "$VAULT_PATH")

  echo -e "  ${BOLD}Setting up your second brain...${RESET}"
  print_blank

  if [[ -d "$VAULT_PATH" ]]; then
    echo -e "  ${DIM}Vault directory exists — merging scaffold (won't overwrite your files)${RESET}"
  fi

  mkdir -p "$VAULT_PATH"

  # Copy scaffold without overwriting existing files
  cp -rn "$SCRIPT_DIR/vault-scaffold/"* "$VAULT_PATH/" 2>/dev/null || true
  cp -rn "$SCRIPT_DIR/vault-scaffold/".* "$VAULT_PATH/" 2>/dev/null || true

  # Clean up .gitkeep files
  find "$VAULT_PATH" -name ".gitkeep" -delete 2>/dev/null || true

  sleep 0.1
  print_success "Created vault at ${BOLD}${display_vault_path}${RESET}"
}

install_commands() {
  local commands_dir="${COMMANDS_DIR_OVERRIDE:-$HOME/.claude/commands}"
  mkdir -p "$commands_dir"

  # Categorize each command: new, current, changed
  local new_cmds=()
  local current_cmds=()
  local changed_cmds=()
  local changed_reasons=()

  for file in "$SCRIPT_DIR/commands/"*.md; do
    local filename cmd_name target new_content
    filename=$(basename "$file")
    cmd_name=$(basename "$filename" .md)
    target="$commands_dir/$filename"
    new_content=$(sed "s/{{VAULT_NAME}}/$VAULT_NAME/g" "$file")

    if [[ ! -f "$target" ]]; then
      new_cmds+=("$cmd_name")
    elif [[ "$new_content" == "$(cat "$target")" ]]; then
      current_cmds+=("$cmd_name")
    else
      changed_cmds+=("$cmd_name")
      # Figure out why it differs
      local existing_vault
      existing_vault=$(grep -o 'vault="[^"]*"' "$target" 2>/dev/null | head -1 | sed 's/vault="//;s/"//')
      if [[ -n "$existing_vault" && "$existing_vault" != "$VAULT_NAME" ]]; then
        changed_reasons+=("vault: ${existing_vault}")
      else
        changed_reasons+=("modified")
      fi
    fi
  done

  print_blank

  # Show what we found
  local total=$(( ${#new_cmds[@]} + ${#current_cmds[@]} + ${#changed_cmds[@]} ))
  local all_cmds=()
  local all_statuses=()
  local all_details=()

  for cmd in "${new_cmds[@]}"; do
    all_cmds+=("$cmd"); all_statuses+=("new"); all_details+=("")
  done
  for cmd in "${current_cmds[@]}"; do
    all_cmds+=("$cmd"); all_statuses+=("current"); all_details+=("")
  done
  for i in "${!changed_cmds[@]}"; do
    all_cmds+=("${changed_cmds[$i]}"); all_statuses+=("changed"); all_details+=("${changed_reasons[$i]}")
  done

  local last=$(( ${#all_cmds[@]} - 1 ))
  for i in "${!all_cmds[@]}"; do
    local connector="├─"
    [[ $i -eq $last ]] && connector="└─"
    local cmd="${all_cmds[$i]}"
    local status="${all_statuses[$i]}"

    # Pad command name for alignment
    local padded
    padded=$(printf "%-28s" "/${cmd}")

    case "$status" in
      new)
        echo -e "     ${DIM}${connector}${RESET} ${CYAN}${padded}${RESET} ${GREEN}new${RESET}"
        ;;
      current)
        echo -e "     ${DIM}${connector}${RESET} ${CYAN}${padded}${RESET} ${DIM}up to date${RESET}"
        ;;
      changed)
        echo -e "     ${DIM}${connector}${RESET} ${CYAN}${padded}${RESET} ${YELLOW}exists${RESET} ${DIM}(${all_details[$i]})${RESET}"
        ;;
    esac
  done

  print_blank

  # Install new commands
  for cmd in "${new_cmds[@]}"; do
    local src="$SCRIPT_DIR/commands/${cmd}.md"
    sed "s/{{VAULT_NAME}}/$VAULT_NAME/g" "$src" > "$commands_dir/${cmd}.md"
  done

  if [[ ${#new_cmds[@]} -gt 0 ]]; then
    print_success "Installed ${BOLD}${#new_cmds[@]}${RESET} new command(s)"
  fi

  if [[ ${#current_cmds[@]} -gt 0 ]]; then
    print_success "${BOLD}${#current_cmds[@]}${RESET} command(s) already up to date"
  fi

  # Handle changed commands
  if [[ ${#changed_cmds[@]} -gt 0 ]]; then
    # Check if they're all from a different vault
    local other_vault=""
    for reason in "${changed_reasons[@]}"; do
      if [[ "$reason" == vault:* ]]; then
        other_vault="${reason#vault: }"
      fi
    done

    print_blank
    if [[ -n "$other_vault" ]]; then
      echo -e "  ${YELLOW}${BOLD}${#changed_cmds[@]} command(s) already exist${RESET}"
      echo -e "  ${DIM}Currently configured for vault ${BOLD}\"${other_vault}\"${RESET}${DIM}.${RESET}"
    else
      echo -e "  ${YELLOW}${BOLD}${#changed_cmds[@]} command(s) have local changes${RESET}"
      echo -e "  ${DIM}The installed versions differ from this template.${RESET}"
    fi

    print_blank
    echo -ne "  Overwrite them? ${DIM}(y/N)${RESET} "
    read -r -n 1 reply
    echo ""

    if [[ "$reply" =~ ^[Yy]$ ]]; then
      for cmd in "${changed_cmds[@]}"; do
        local src="$SCRIPT_DIR/commands/${cmd}.md"
        sed "s/{{VAULT_NAME}}/$VAULT_NAME/g" "$src" > "$commands_dir/${cmd}.md"
      done
      print_success "Updated ${BOLD}${#changed_cmds[@]}${RESET} command(s)"
    else
      print_info "Skipped — existing commands untouched"
    fi
  fi
}

# ─── TUI Helpers ─────────────────────────────────────────────────────────────

PICK_RESULT=""

hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
cursor_up()   { printf '\033[%dA' "$1"; }
clear_line()  { printf '\r\033[K'; }

trap 'show_cursor' EXIT
trap 'show_cursor; exit 1' INT

read_key() {
  local key rest
  IFS= read -rsn1 key 2>/dev/null

  if [[ "$key" == $'\x1b' ]]; then
    IFS= read -rsn2 -t 1 rest 2>/dev/null
    case "$rest" in
      '[A') echo "up" ;;
      '[B') echo "down" ;;
      '[C') echo "right" ;;
      '[D') echo "left" ;;
      *)    echo "escape" ;;
    esac
  elif [[ "$key" == "" ]]; then
    echo "enter"
  elif [[ "$key" == " " ]]; then
    echo "space"
  else
    echo "other"
  fi
}

# ─── Clack-style Bar ────────────────────────────────────────────────────────

# The vertical bar prefix for all interview output
BAR="${DIM}│${RESET}"
BAR_SPACE="${DIM}│${RESET}  "

bar_blank() { echo -e "  ${BAR}"; }
bar_text()  { echo -e "  ${BAR_SPACE}$*${RESET}"; }
bar_open()  { echo -e "  ${DIM}┌${RESET}  ${BOLD}$*${RESET}"; }
bar_close() { echo -e "  ${DIM}└${RESET}  $*${RESET}"; }

bar_step() {
  echo -e "  ${CYAN}◆${RESET}  ${BOLD}$*${RESET}"
}

bar_done() {
  local label="$1" value="$2"
  echo -e "  ${GREEN}◇${RESET}  ${DIM}${label}${RESET} ${GREEN}${value}${RESET}"
}

bar_skip() {
  local label="$1"
  echo -e "  ${DIM}◇${RESET}  ${DIM}${label} · skipped${RESET}"
}

# ─── Grid Pickers ───────────────────────────────────────────────────────────

compute_grid() {
  local count=$1
  shift
  local options=("$@")

  local max_len=0
  for opt in "${options[@]}"; do
    local len=${#opt}
    if [[ $len -gt $max_len ]]; then max_len=$len; fi
  done

  GRID_COL_WIDTH=$((max_len + 6))

  local term_width
  term_width=$(tput cols 2>/dev/null || echo 80)
  local available=$((term_width - 10))  # account for bar prefix

  GRID_COLS=$((available / GRID_COL_WIDTH))
  if [[ $GRID_COLS -lt 2 ]]; then GRID_COLS=2; fi
  if [[ $GRID_COLS -gt 4 ]]; then GRID_COLS=4; fi
  if [[ $GRID_COLS -gt $count ]]; then GRID_COLS=$count; fi

  GRID_ROWS=$(( (count + GRID_COLS - 1) / GRID_COLS ))
}

pad_to() {
  local text="$1" width="$2"
  local pad=$((width - ${#text}))
  printf '%s' "$text"
  if [[ $pad -gt 0 ]]; then printf "%${pad}s" ""; fi
}

# Single-select grid row (inside bar)
draw_bar_row_single() {
  local row=$1 cursor=$2 cols=$3 col_width=$4 count=$5
  shift 5
  local options=("$@")
  local line="  ${BAR_SPACE}"

  for (( c=0; c<cols; c++ )); do
    local idx=$((row * cols + c))
    if [[ $idx -ge $count ]]; then break; fi

    local text="${options[$idx]}"
    if [[ $idx -eq $cursor ]]; then
      line+="${CYAN}❯ $(pad_to "$text" $((col_width - 4)))${RESET}"
    else
      line+="${DIM}  $(pad_to "$text" $((col_width - 4)))${RESET}"
    fi
  done

  echo -e "$line"
}

# Multi-select grid row (inside bar). Uses _MULTI_OPTIONS / _MULTI_TOGGLED.
draw_bar_row_multi() {
  local row=$1 cursor=$2 cols=$3 col_width=$4 count=$5
  local line="  ${BAR_SPACE}"

  for (( c=0; c<cols; c++ )); do
    local idx=$((row * cols + c))
    if [[ $idx -ge $count ]]; then break; fi

    local text="${_MULTI_OPTIONS[$idx]}"
    local check="○"
    [[ "${_MULTI_TOGGLED[$idx]}" == "1" ]] && check="●"

    if [[ $idx -eq $cursor ]]; then
      line+="${CYAN}❯ ${check} $(pad_to "$text" $((col_width - 6)))${RESET}"
    elif [[ "${_MULTI_TOGGLED[$idx]}" == "1" ]]; then
      line+="${GREEN}  ${check} $(pad_to "$text" $((col_width - 6)))${RESET}"
    else
      line+="${DIM}  ${check} $(pad_to "$text" $((col_width - 6)))${RESET}"
    fi
  done

  echo -e "$line"
}

# Single-select picker (renders inside the bar)
pick_one() {
  local question="$1"
  shift
  local options=("$@" "Type my own...")
  local count=${#options[@]}
  local cursor=0
  local custom_idx=$((count - 1))

  compute_grid "$count" "${options[@]}"
  local cols=$GRID_COLS rows=$GRID_ROWS cw=$GRID_COL_WIDTH

  bar_step "$question"
  bar_blank

  hide_cursor

  local menu_lines=$((rows + 2))  # rows + blank + hint
  for (( r=0; r<rows; r++ )); do
    draw_bar_row_single "$r" "$cursor" "$cols" "$cw" "$count" "${options[@]}"
  done
  bar_blank
  bar_text "${DIM}←/→/↑/↓ navigate · enter select${RESET}"

  while true; do
    local key
    key=$(read_key)
    local row=$((cursor / cols)) col=$((cursor % cols))

    case "$key" in
      up)    if [[ $row -gt 0 ]]; then cursor=$((cursor - cols)); fi ;;
      down)  local n=$((cursor + cols)); if [[ $n -lt $count ]]; then cursor=$n; fi ;;
      left)  if [[ $col -gt 0 ]]; then cursor=$((cursor - 1)); fi ;;
      right) local n=$((cursor + 1)); if [[ $n -lt $count && $col -lt $((cols - 1)) ]]; then cursor=$n; fi ;;
      enter) break ;;
    esac

    cursor_up "$menu_lines"
    for (( r=0; r<rows; r++ )); do
      clear_line
      draw_bar_row_single "$r" "$cursor" "$cols" "$cw" "$count" "${options[@]}"
    done
    clear_line; bar_blank
    clear_line; bar_text "${DIM}←/→/↑/↓ navigate · enter select${RESET}"
  done

  # Clear menu and step marker (menu_lines + 2 for step + blank above)
  local total_lines=$((menu_lines + 2))
  cursor_up "$total_lines"
  for (( i=0; i<total_lines; i++ )); do clear_line; echo ""; done
  cursor_up "$total_lines"

  show_cursor

  if [[ $cursor -eq $custom_idx ]]; then
    bar_step "$question"
    echo -ne "  ${BAR_SPACE}${CYAN}▸${RESET} "
    read -r PICK_RESULT
    # Rewrite as completed
    cursor_up 2
    clear_line; clear_line
  else
    PICK_RESULT="${options[$cursor]}"
  fi

  bar_done "$question ·" "$PICK_RESULT"
}

# Multi-select picker (renders inside the bar)
pick_multiple() {
  local question="$1"
  shift
  _MULTI_OPTIONS=("$@")
  local count=${#_MULTI_OPTIONS[@]}
  local cursor=0
  _MULTI_TOGGLED=()
  for (( i=0; i<count; i++ )); do _MULTI_TOGGLED[$i]=0; done

  compute_grid "$count" "${_MULTI_OPTIONS[@]}"
  local cols=$GRID_COLS rows=$GRID_ROWS cw=$GRID_COL_WIDTH

  bar_step "$question"
  bar_blank

  hide_cursor

  local menu_lines=$((rows + 2))
  local hint="${DIM}←/→/↑/↓ navigate · space toggle · enter confirm${RESET}"
  local skip_pending=false

  for (( r=0; r<rows; r++ )); do
    draw_bar_row_multi "$r" "$cursor" "$cols" "$cw" "$count"
  done
  bar_blank
  bar_text "$hint"

  while true; do
    local key
    key=$(read_key)
    local row=$((cursor / cols)) col=$((cursor % cols))

    # Any key other than enter cancels skip confirmation
    if [[ "$key" != "enter" ]]; then
      skip_pending=false
    fi

    case "$key" in
      up)    if [[ $row -gt 0 ]]; then cursor=$((cursor - cols)); fi ;;
      down)  local n=$((cursor + cols)); if [[ $n -lt $count ]]; then cursor=$n; fi ;;
      left)  if [[ $col -gt 0 ]]; then cursor=$((cursor - 1)); fi ;;
      right) local n=$((cursor + 1)); if [[ $n -lt $count && $col -lt $((cols - 1)) ]]; then cursor=$n; fi ;;
      space)
        if [[ "${_MULTI_TOGGLED[$cursor]}" == "0" ]]; then
          _MULTI_TOGGLED[$cursor]=1
        else
          _MULTI_TOGGLED[$cursor]=0
        fi
        ;;
      enter)
        # Check if anything is selected
        local has_selection=false
        for (( i=0; i<count; i++ )); do
          if [[ "${_MULTI_TOGGLED[$i]}" == "1" ]]; then has_selection=true; break; fi
        done
        if [[ "$has_selection" == "true" ]]; then
          break
        elif [[ "$skip_pending" == "true" ]]; then
          break
        else
          skip_pending=true
          hint="${YELLOW}Nothing selected — enter again to skip${RESET}"
        fi
        ;;
    esac

    cursor_up "$menu_lines"
    for (( r=0; r<rows; r++ )); do
      clear_line
      draw_bar_row_multi "$r" "$cursor" "$cols" "$cw" "$count"
    done
    clear_line; bar_blank
    clear_line; bar_text "$hint"

    # Reset hint after redraw if not skip-pending
    if [[ "$skip_pending" == "false" ]]; then
      hint="${DIM}←/→/↑/↓ navigate · space toggle · enter confirm${RESET}"
    fi
  done

  # Clear menu + step marker
  local total_lines=$((menu_lines + 2))
  cursor_up "$total_lines"
  for (( i=0; i<total_lines; i++ )); do clear_line; echo ""; done
  cursor_up "$total_lines"

  show_cursor

  # Build result
  PICK_RESULT=""
  for i in "${!_MULTI_OPTIONS[@]}"; do
    if [[ "${_MULTI_TOGGLED[$i]}" == "1" ]]; then
      if [[ -n "$PICK_RESULT" ]]; then PICK_RESULT+=", "; fi
      PICK_RESULT+="${_MULTI_OPTIONS[$i]}"
    fi
  done

  # Custom additions
  bar_step "$question"
  if [[ -n "$PICK_RESULT" ]]; then
    bar_text "${GREEN}${PICK_RESULT}${RESET}"
  fi
  bar_text "${DIM}Add more? (blank to continue)${RESET}"
  echo -ne "  ${BAR_SPACE}${CYAN}▸${RESET} "
  read -r extra
  if [[ -n "$extra" ]]; then
    if [[ -n "$PICK_RESULT" ]]; then
      PICK_RESULT="${PICK_RESULT}, ${extra}"
    else
      PICK_RESULT="$extra"
    fi
  fi

  # Rewrite as completed
  local add_lines=3
  if [[ -n "$PICK_RESULT" ]]; then add_lines=4; fi
  cursor_up "$add_lines"
  for (( i=0; i<add_lines; i++ )); do clear_line; echo ""; done
  cursor_up "$add_lines"

  if [[ -n "$PICK_RESULT" ]]; then
    bar_done "$question ·" "$PICK_RESULT"
  else
    bar_skip "$question"
  fi
}

# ─── Profile Interview ────────────────────────────────────────────────────────

ANS_NAME=""
ANS_ROLES=""
ANS_INTERESTS=""
ANS_SOURCE_TYPE=""   # file, url, search, none
ANS_SOURCE=""
INTERVIEW_DONE=false

ask_name() {
  bar_step "What's your name?"
  while true; do
    echo -ne "  ${BAR_SPACE}${CYAN}▸${RESET} "
    read -r ANS_NAME
    if [[ -n "$ANS_NAME" ]]; then break; fi
    bar_text "${RED}This one's needed${RESET}"
  done
  cursor_up 2; clear_line; echo ""; clear_line; cursor_up 2
  bar_done "Name ·" "$ANS_NAME"
}

ask_roles() {
  pick_multiple "What do you do?" \
    "I write code" \
    "I make pixels behave" \
    "I ship products" \
    "I wrangle data" \
    "I keep things running" \
    "I'm figuring it out"
  ANS_ROLES="$PICK_RESULT"
}

ask_interests() {
  pick_multiple "What are you into?" \
    "Music" \
    "Gaming" \
    "Sports / Fitness" \
    "Reading" \
    "Cooking" \
    "Travel" \
    "Photography" \
    "Art / Design" \
    "Writing" \
    "Open source"
  ANS_INTERESTS="$PICK_RESULT"
}

ask_source() {
  pick_one "Got a resume, profile, or doc to pull from?" \
    "File on disk" \
    "Website URL" \
    "Search the web" \
    "Skip"

  case "$PICK_RESULT" in
    "File on disk")
      ANS_SOURCE_TYPE="file"
      bar_step "Enter the file path"
      echo -ne "  ${BAR_SPACE}${CYAN}▸${RESET} "
      read -r ANS_SOURCE
      ANS_SOURCE="${ANS_SOURCE/#\~/$HOME}"
      cursor_up 2; clear_line; echo ""; clear_line; cursor_up 2
      if [[ -n "$ANS_SOURCE" && -f "$ANS_SOURCE" ]]; then
        bar_done "Source ·" "$(display_path "$ANS_SOURCE")"
      else
        bar_text "${YELLOW}File not found — skipping${RESET}"
        ANS_SOURCE_TYPE="none"; ANS_SOURCE=""
      fi
      ;;
    "Website URL")
      ANS_SOURCE_TYPE="url"
      bar_step "Paste the URL"
      echo -ne "  ${BAR_SPACE}${CYAN}▸${RESET} "
      read -r ANS_SOURCE
      cursor_up 2; clear_line; echo ""; clear_line; cursor_up 2
      if [[ -n "$ANS_SOURCE" ]]; then
        bar_done "Source ·" "$ANS_SOURCE"
      else
        bar_skip "Source"; ANS_SOURCE_TYPE="none"
      fi
      ;;
    "Search the web")
      ANS_SOURCE_TYPE="search"
      bar_step "What should Claude search for? ${DIM}(name, company, GitHub...)${RESET}"
      echo -ne "  ${BAR_SPACE}${CYAN}▸${RESET} "
      read -r ANS_SOURCE
      cursor_up 2; clear_line; echo ""; clear_line; cursor_up 2
      if [[ -n "$ANS_SOURCE" ]]; then
        bar_done "Source ·" "search: ${ANS_SOURCE}"
      else
        bar_skip "Source"; ANS_SOURCE_TYPE="none"
      fi
      ;;
    *)
      ANS_SOURCE_TYPE="none"; ANS_SOURCE=""
      ;;
  esac
}

show_review() {
  bar_blank
  bar_step "Review"
  bar_blank

  bar_text "${BOLD}Name${RESET}       ${ANS_NAME}"
  bar_text "${BOLD}I do${RESET}       ${ANS_ROLES:--}"
  bar_text "${BOLD}Into${RESET}       ${ANS_INTERESTS:--}"

  case "$ANS_SOURCE_TYPE" in
    file)   bar_text "${BOLD}Source${RESET}     $(display_path "$ANS_SOURCE")" ;;
    url)    bar_text "${BOLD}Source${RESET}     ${ANS_SOURCE}" ;;
    search) bar_text "${BOLD}Source${RESET}     search: ${ANS_SOURCE}" ;;
  esac

  bar_blank
}

run_interview() {
  print_blank
  echo -e "  ${DIM}───────────────────────────────────────${RESET}"
  print_blank
  echo -e "  ${DIM}A few quick questions so Claude Code can fill in your vault.${RESET}"
  print_blank

  echo -ne "  Set up your profile now? ${DIM}(Y/n)${RESET} "
  read -r -n 1 reply
  echo ""
  if [[ "$reply" =~ ^[Nn]$ ]]; then
    return
  fi
  print_blank

  bar_open "Profile Setup"
  bar_blank

  ask_name
  ask_roles
  ask_interests
  ask_source

  # ── Review ──

  while true; do
    show_review

    pick_one "All good?" \
      "Looks good, let's go" \
      "Edit name" \
      "Edit what I do" \
      "Edit interests" \
      "Edit source"

    case "$PICK_RESULT" in
      "Looks good, let's go") break ;;
      "Edit name")        ask_name ;;
      "Edit what I do")   ask_roles ;;
      "Edit interests")   ask_interests ;;
      "Edit source")      ask_source ;;
    esac
  done

  bar_blank
  bar_close "${GREEN}Profile ready${RESET}"
  print_blank

  INTERVIEW_DONE=true
}

build_prompt() {
  local prompt=""
  prompt+="You are setting up a Second Brain vault for a new user. Based on their interview answers below, fill in the vault notes in the Me/ folder.\n\n"
  prompt+="## Interview Answers\n\n"
  prompt+="**Name:** ${ANS_NAME}\n"

  if [[ -n "$ANS_ROLES" ]]; then
    prompt+="**What they do:** ${ANS_ROLES}\n"
  fi

  if [[ -n "$ANS_INTERESTS" ]]; then
    prompt+="**Interests:** ${ANS_INTERESTS}\n"
  fi

  case "$ANS_SOURCE_TYPE" in
    file)
      prompt+="\n## Reference Document\n\n"
      prompt+="Read this file and extract any relevant details (roles, dates, skills, education, links): ${ANS_SOURCE}\n"
      ;;
    url)
      prompt+="\n## Reference URL\n\n"
      prompt+="Fetch this URL and extract any relevant details (roles, dates, skills, education, links): ${ANS_SOURCE}\n"
      ;;
    search)
      prompt+="\n## Web Search\n\n"
      prompt+="Search the web for: ${ANS_SOURCE}\n"
      prompt+="Extract any relevant details about this person (roles, background, projects, links).\n"
      ;;
  esac

  prompt+="\n## Instructions\n\n"
  prompt+="Fill in these vault notes based on the information above. Read each file first, then edit it:\n\n"
  prompt+="- **Me/About Me.md** — Name, location, bio, background, links. Add a Basics section with bullet points and a Bio section with prose.\n"
  prompt+="- **Me/Work & Career.md** — Current and past roles, skills, experience areas. Organize by role with dates if available.\n"
  prompt+="- **Me/Goals.md** — Fill in Current, This Year, and Long-term sections based on what they shared.\n"
  prompt+="- **Me/Preferences.md** — Work style, communication style, tools, any opinions or preferences mentioned.\n"
  prompt+="- **Me/Interests & Hobbies.md** — Anything non-work they mentioned.\n"
  prompt+="\n"
  prompt+="Rules:\n"
  prompt+="- Keep the existing YAML frontmatter in each file — don't change tags or title.\n"
  prompt+="- Replace the <!-- comment --> placeholders with real content.\n"
  prompt+="- Use Obsidian wikilinks (e.g. [[Work & Career]]) to cross-reference between notes.\n"
  prompt+="- Write naturally — not robotic. Match the tone of what they shared.\n"
  prompt+="- If there's not enough info for a section, leave a helpful <!-- prompt --> comment instead of fabricating.\n"
  prompt+="- If a reference document or URL was provided, extract everything useful from it.\n"

  echo -e "$prompt"
}

launch_profile_setup() {
  if [[ "$INTERVIEW_DONE" != "true" ]]; then
    return
  fi

  echo -e "  ${DIM}───────────────────────────────────────${RESET}"
  print_blank
  echo -e "  ${BOLD}Ready to populate your vault notes${RESET}"
  print_blank
  echo -e "  ${DIM}Claude Code will use your answers to fill in:${RESET}"
  echo -e "  ${DIM}About Me, Work & Career, Goals, Preferences, Interests${RESET}"
  print_blank

  local prompt_file="$VAULT_PATH/.setup-prompt.md"
  build_prompt > "$prompt_file"

  if [[ "$DRY_RUN" == "true" ]]; then
    local prompt_preview
    prompt_preview=$(build_prompt)
    local char_count=${#prompt_preview}
    echo -e "  ${DIM}Generated prompt (${char_count} chars):${RESET}"
    print_blank
    echo "$prompt_preview" | head -10 | sed 's/^/  /'
    echo -e "  ${DIM}...${RESET}"
    print_blank
    print_success "${MAGENTA}Would launch Claude Code here${RESET}"
    print_blank
    rm -f "$prompt_file"
    return
  fi

  if check_claude_code; then
    echo -ne "  Launch Claude Code now? ${DIM}(Y/n)${RESET} "
    read -r -n 1 reply
    echo ""
    print_blank

    if [[ ! "$reply" =~ ^[Nn]$ ]]; then
      echo -e "  ${DIM}Starting Claude Code in your vault...${RESET}"
      echo -e "  ${DIM}Review and approve the file edits, then exit when done.${RESET}"
      print_blank

      local prompt_text
      prompt_text=$(build_prompt)

      # Launch claude interactively with the prompt
      (cd "$VAULT_PATH" && claude "$prompt_text")

      print_blank
      print_success "Profile setup session complete"
      print_blank

      # Clean up prompt file
      rm -f "$prompt_file"
      return
    fi
  fi

  # Fallback: save prompt to file
  echo -e "  ${BOLD}Prompt saved to:${RESET}"
  echo -e "     ${CYAN}$(display_path "$prompt_file")${RESET}"
  print_blank
  echo -e "  ${DIM}To use it, run Claude Code in your vault directory:${RESET}"
  echo -e "     ${CYAN}cd $(display_path "$VAULT_PATH")${RESET}"
  echo -e "     ${CYAN}claude${RESET}"
  echo -e "  ${DIM}Then paste the contents of the prompt file.${RESET}"
  print_blank

  # Also try clipboard
  if command -v pbcopy &>/dev/null; then
    build_prompt | pbcopy
    print_success "Prompt also copied to clipboard"
    print_blank
  fi
}

# ─── Next Steps ───────────────────────────────────────────────────────────────

print_next_steps() {
  local display_vault_path
  display_vault_path=$(display_path "$VAULT_PATH")

  print_blank
  echo -e "  ${DIM}───────────────────────────────────────${RESET}"
  print_blank

  # Success banner with gradient
  local done_color
  done_color=$(gradient_color 3 11)
  echo -e "  ${done_color}${BOLD}Setup complete!${RESET}"
  print_blank

  echo -e "  ${BOLD}Next steps${RESET}"
  print_blank

  local step=1

  echo -e "  ${CYAN}${step}${RESET}  Open Obsidian and add vault at:"
  echo -e "     ${BOLD}${display_vault_path}${RESET}"
  print_blank
  step=$((step + 1))

  if [[ "$INTERVIEW_DONE" != "true" ]]; then
    echo -e "  ${CYAN}${step}${RESET}  Fill in your notes in ${BOLD}Me/${RESET}"
    echo -e "     ${DIM}Start with About Me.md — this is what Claude reads first${RESET}"
    print_blank
    step=$((step + 1))
  fi

  if ! check_obsidian_skills; then
    echo -e "  ${CYAN}${step}${RESET}  Install the obsidian-skills plugin:"
    echo -e "     ${CYAN}claude install obsidian-skills${RESET}"
    print_blank
    step=$((step + 1))
  fi

  echo -e "  ${CYAN}${step}${RESET}  Try it out:"
  echo -e "     ${CYAN}claude${RESET}  ${DIM}then run${RESET}  ${CYAN}/context-me${RESET}"
  print_blank

  echo -e "  ${DIM}Docs: https://github.com/areyouwhy/second-brain${RESET}"
  print_blank
}

# ─── Help ─────────────────────────────────────────────────────────────────────

print_help() {
  setup_colors
  echo ""
  echo -e "  ${BOLD}Second Brain${RESET} — Obsidian + Claude Code setup"
  echo ""
  echo -e "  ${DIM}Usage:${RESET}  ./setup.sh [--dry-run]"
  echo ""
  echo -e "  Interactive setup that:"
  echo -e "    1. Checks prerequisites (Obsidian, Claude Code, obsidian-skills)"
  echo -e "    2. Creates an Obsidian vault with starter notes"
  echo -e "    3. Installs 10 Claude Code slash commands for your vault"
  echo -e "    4. Optionally interviews you and launches Claude Code to"
  echo -e "       fill in your vault notes automatically"
  echo ""
  echo -e "  ${DIM}https://github.com/areyouwhy/second-brain${RESET}"
  echo ""
}

# ─── Dry Run ──────────────────────────────────────────────────────────────────

DRY_RUN=false

setup_dry_run() {
  DRY_RUN=true
  local tmpdir
  tmpdir=$(mktemp -d)

  # Redirect vault and commands to temp directories
  VAULT_PATH_OVERRIDE="$tmpdir/vault"
  COMMANDS_DIR_OVERRIDE="$tmpdir/commands"
  mkdir -p "$COMMANDS_DIR_OVERRIDE"

  # Copy existing commands so conflict detection works realistically
  if [[ -d "$HOME/.claude/commands" ]]; then
    cp "$HOME/.claude/commands/"*.md "$COMMANDS_DIR_OVERRIDE/" 2>/dev/null || true
  fi

  echo -e "  ${MAGENTA}${BOLD}DRY RUN${RESET} ${DIM}— nothing will be installed${RESET}"
  echo -e "  ${DIM}Temp dir: ${tmpdir}${RESET}"
  print_blank

  # Clean up on exit
  trap "rm -rf '$tmpdir'" EXIT
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    print_help
    exit 0
  fi

  setup_colors

  if [[ "${1:-}" == "--dry-run" ]]; then
    print_header
    setup_dry_run
  else
    print_header
  fi

  check_prerequisites
  prompt_vault_name
  prompt_vault_path

  # In dry-run mode, override paths after prompts
  if [[ "$DRY_RUN" == "true" ]]; then
    VAULT_PATH="$VAULT_PATH_OVERRIDE"
  fi

  confirm_setup
  create_vault
  install_commands
  run_interview
  launch_profile_setup
  print_next_steps

  if [[ "$DRY_RUN" == "true" ]]; then
    print_blank
    echo -e "  ${MAGENTA}${BOLD}DRY RUN COMPLETE${RESET} ${DIM}— nothing was installed to your system${RESET}"
    print_blank
  fi
}

main "$@"

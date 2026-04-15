#!/usr/bin/env bash
# setup-folders.sh — Create Cowork Project folder structure for a preset (macOS)
# Usage: ./scripts/setup-folders.sh [preset-name]
# If preset-name is not provided, the script will prompt you.

set -euo pipefail

# --- Supported presets and their subfolder lists ---
declare -A PRESET_FOLDERS
PRESET_FOLDERS["study"]="Papers Notes Flashcards Assignments Resources"
PRESET_FOLDERS["research"]="Literature Notes Drafts Data References"
PRESET_FOLDERS["writing"]="Drafts Published Ideas Research Voice-and-Style"
PRESET_FOLDERS["project-management"]="Active-Projects Archive Templates Meeting-Notes Inbox"
PRESET_FOLDERS["creative"]="Projects Inspiration Drafts Assets Archive"
PRESET_FOLDERS["business-admin"]="Inbox Reports Emails Meetings Templates"

VALID_PRESETS="study, research, writing, project-management, creative, business-admin"

# --- Get preset name ---
PRESET="${1:-}"

if [ -z "$PRESET" ]; then
  echo "Which preset would you like to set up?"
  echo "Options: $VALID_PRESETS"
  read -r -p "Preset name: " PRESET
fi

PRESET="$(echo "$PRESET" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

# --- Validate preset name ---
if [ -z "${PRESET_FOLDERS[$PRESET]+_}" ]; then
  echo "Error: '$PRESET' is not a recognized preset." >&2
  echo "Valid presets: $VALID_PRESETS" >&2
  exit 1
fi

# --- Build target path ---
DEFAULT_BASE="$HOME/Documents/Claude/Projects"
TARGET="$DEFAULT_BASE/$PRESET"

# --- Path validation (S3 carry-forward) ---
# Reject path traversal
if echo "$TARGET" | grep -q '\.\.'; then
  echo "Error: Path traversal detected in target path. Aborting." >&2
  exit 1
fi

# Reject system directories
SYSTEM_DIRS="/usr /etc /bin /sbin /System /Library"
for sys_dir in $SYSTEM_DIRS; do
  if [ "$TARGET" = "$sys_dir" ] || [[ "$TARGET" == "$sys_dir/"* ]]; then
    echo "Error: Cannot create folders inside system directory: $sys_dir" >&2
    exit 1
  fi
done

# Reject $HOME root itself (must be in a subdirectory)
if [ "$TARGET" = "$HOME" ]; then
  echo "Error: Target path cannot be your home directory root." >&2
  exit 1
fi

# Must be inside $HOME
if [[ "$TARGET" != "$HOME/"* ]]; then
  echo "Error: Target path must be inside your home directory ($HOME)." >&2
  exit 1
fi

# --- Confirm with user ---
echo ""
echo "Creating folder structure for preset: $PRESET"
echo "Target location: $TARGET"
echo ""
read -r -p "Proceed? [y/N] " CONFIRM
CONFIRM="$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')"

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "yes" ]; then
  echo "Cancelled."
  exit 0
fi

# --- Create folders ---
echo ""
echo "Creating folders..."

mkdir -p "$TARGET"
echo "  Created: $TARGET"

IFS=' ' read -r -a SUBFOLDERS <<< "${PRESET_FOLDERS[$PRESET]}"
for folder in "${SUBFOLDERS[@]}"; do
  FULL_PATH="$TARGET/$folder"
  mkdir -p "$FULL_PATH"
  echo "  Created: $FULL_PATH"
done

echo ""
echo "Done. Your $PRESET folder structure is ready at:"
echo "  $TARGET"
echo ""
echo "Next step: In Cowork, assign this folder to your Project in Project Settings."

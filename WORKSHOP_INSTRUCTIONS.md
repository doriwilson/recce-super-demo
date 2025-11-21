# Workshop Instructions: Using Pre-Generated Recce State Files

This repository includes pre-generated Recce state files so you can start using Recce immediately without manual setup.

## Quick Start for Workshop Participants

### Step 1: Clone and Setup (5 minutes)

```bash
# Clone the repository
git clone <repository-url>
cd recce-super-demo

# Set up environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure dbt
cp profiles.yml.example profiles.yml

# Install dependencies
dbt deps
dbt seed
```

### Step 2: Run Recce on Main Branch

```bash
# On main branch
git checkout main

# Start Recce server - it will use the pre-generated base artifacts
recce server

# Or view the state file directly
recce run --state-file recce_base_state.json
```

### Step 3: Test PR #1 (Incremental Model Changes)

```bash
# Switch to PR branch
git checkout pr1-incremental-filter

# Run Recce - state file is already generated!
recce server

# The state file compares PR #1 to main automatically
# No need to specify --target-base-path or generate artifacts manually!
```

### Step 4: Test PR #2 (Breaking Change Detection)

```bash
git checkout pr2-model-rename

# Run Recce
recce server

# Recce will show the breaking change (missing stg_orders reference)
```

### Step 5: Test PR #3 (Timestamp Validation)

```bash
git checkout pr3-timestamp-logic

# Run Recce
recce server

# Recce will show timestamp value differences
```

## What's Pre-Generated?

### Main Branch
- `target-base/` - Complete base artifacts (manifest.json, catalog.json, run_results.json)
- `recce_base_state.json` - Base state file for reference

### PR Branches
- `target-base/` - Copied from main (base for comparison)
- `recce_state.json` - Pre-generated comparison state (PR vs main)

## How It Works

When you run `recce server` or `recce run` on a PR branch:

1. Recce automatically finds `target-base/` directory (base artifacts)
2. Recce uses `target/` directory (current branch artifacts)
3. If `recce_state.json` exists, Recce can load it directly
4. No manual `--target-base-path` needed!

## Troubleshooting

**"Cannot load the manifest" error:**
- Ensure you're on the correct branch
- The `target-base/` directory should exist (it's committed to git)

**"State file not found":**
- State files are committed to each branch
- If missing, regenerate: `recce run --target-base-path target-base --target-path target --output recce_state.json`

**Recce server won't start:**
- Check that port 8000 is available
- Try: `recce server --port 8001`

## For Instructors

To regenerate state files after model changes:

```bash
# On main
git checkout main
dbt build
dbt docs generate
mkdir -p target-base
cp -r target/* target-base/
recce run --target-base-path target-base --target-path target --output recce_base_state.json
git add target-base/ recce_base_state.json
git commit -m "Update base artifacts"

# On each PR branch
git checkout pr1-incremental-filter
dbt build
dbt docs generate
recce run --target-base-path target-base --target-path target --output recce_state.json
git add recce_state.json
git commit -m "Update PR #1 state file"
```

---

**Workshop participants can now just `git checkout` and `recce server` - no manual setup needed!** 🎉


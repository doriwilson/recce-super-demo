#!/bin/bash
# setup.sh
# Automated setup script for Super Recce Training
# This script sets up the Python environment, installs dependencies, and builds the base dbt project

set -e  # Exit on error

echo "🚀 Setting up Super Recce Training repository..."

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install dbt-duckdb recce

# Check if profiles.yml exists
if [ ! -f "profiles.yml" ]; then
    if [ -f "profiles.yml.example" ]; then
        echo "📋 Creating profiles.yml from example..."
        cp profiles.yml.example profiles.yml
        echo "⚠️  Please review profiles.yml and update if needed"
    else
        echo "❌ profiles.yml.example not found"
        exit 1
    fi
fi

# Install dbt packages
echo "📚 Installing dbt packages..."
dbt deps

# Seed the database
echo "🌱 Seeding database..."
dbt seed

# Build main branch to prod schema (base data for comparisons)
echo "🔨 Building main branch to prod schema (base data for comparisons)..."
dbt build --target prod

# Generate artifacts for Recce
echo "📊 Generating artifacts for prod..."
dbt docs generate --target prod

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review the README.md for training instructions"
echo "  2. Check out PR branches: git checkout pr1-incremental-filter"
echo "  3. Build PR branch to dev: dbt build --target dev"
echo "  4. Run Recce: recce server recce_state.json"
echo ""


# GitHub Repository Setup Guide

Since GitHub CLI (`gh`) is not installed, follow these steps to create and push your repository to GitHub.

## Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `recce-super-demo`
3. Description: `Super Recce Training Repository - Hands-on training for data analysts`
4. Choose: **Public** (or Private if you prefer)
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click **"Create repository"**

## Step 2: Connect Local Repository to GitHub

After creating the repository, GitHub will show you commands. Use these:

```bash
cd /Users/doriwilson/Documents/Recce/recce-super-demo

# Make initial commit (if not already done)
git add -A
git commit -m "Initial commit: Super Recce Training repository

- Complete dbt project with DuckDB
- Three training PRs configured
- Recce Cloud CI workflow ready
- All models verified and working"

# Add GitHub remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/recce-super-demo.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

## Step 3: Verify Push

1. Go to your repository on GitHub: `https://github.com/YOUR_USERNAME/recce-super-demo`
2. Verify all files are there
3. Check that the `.github/workflows/recce-ci.yml` file exists

## Step 4: Set Up Recce Cloud CI

1. In your GitHub repository, go to **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Name: `RECCE_API_KEY`
4. Value: Get your API key from https://cloud.recce.dev/settings/api-keys
5. Click **"Add secret"**

### Optional: Set Project ID

If you have multiple Recce Cloud projects:

1. Create another secret: `RECCE_PROJECT_ID`
2. Value: Your project ID from Recce Cloud

## Step 5: Test the CI Workflow

1. Create a test branch:
   ```bash
   git checkout -b test-ci
   # Make a small change (e.g., add a comment to README.md)
   git add README.md
   git commit -m "Test CI workflow"
   git push -u origin test-ci
   ```

2. Create a Pull Request on GitHub
3. Go to the **Actions** tab to see the workflow run
4. Check the PR for Recce validation results

## Alternative: Install GitHub CLI (Optional)

If you want to use GitHub CLI in the future:

```bash
# On macOS
brew install gh

# Authenticate
gh auth login

# Then you can create repos with:
gh repo create recce-super-demo --public --source=. --remote=origin --push
```

## Troubleshooting

### "Repository not found" error
- Check that the repository name matches exactly
- Verify you have push access to the repository
- Try using SSH instead: `git remote set-url origin git@github.com:YOUR_USERNAME/recce-super-demo.git`

### "Permission denied" error
- Make sure you're authenticated with GitHub
- For HTTPS, you may need a Personal Access Token instead of password
- For SSH, make sure your SSH key is added to GitHub

### Workflow not running
- Check that `.github/workflows/recce-ci.yml` exists in the repository
- Verify GitHub Actions is enabled in repository settings
- Check the Actions tab for any error messages

---

**Once pushed, your repository will be ready for training!** 🚀


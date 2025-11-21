# Recce Cloud CI Setup Guide

This guide walks you through setting up Recce Cloud for automated CI/CD validation in your GitHub repository.

## Prerequisites

- ✅ GitHub account connected to Recce Cloud
- ✅ Access to Recce Cloud organization (you mentioned you already have this)
- ✅ Repository with dbt project

## Step 1: Get Your Recce Cloud API Key

1. Log in to [Recce Cloud](https://cloud.recce.dev)
2. Navigate to **Settings** → **API Keys**
3. Click **Create API Key**
4. Give it a name (e.g., "GitHub Actions CI")
5. Copy the API key (you'll only see it once!)

## Step 2: Add API Key to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `RECCE_API_KEY`
5. Value: Paste your API key from Step 1
6. Click **Add secret**

### Optional: Set Project ID

If you have multiple Recce Cloud projects:

1. Get your Project ID from Recce Cloud (Settings → Project)
2. Create another secret: `RECCE_PROJECT_ID`
3. Value: Your project ID

## Step 3: Verify Workflow is Enabled

The workflow file (`.github/workflows/recce-ci.yml`) is already configured. It will:

- ✅ Run automatically on every PR to `main`
- ✅ Build baseline from `main` branch
- ✅ Build PR branch
- ✅ Run Recce Cloud comparison
- ✅ Post results as PR comment

## Step 4: Test the Setup

1. Create a test PR (or use one of the training PRs)
2. Push to GitHub
3. Check the **Actions** tab in your repository
4. You should see "Recce Cloud CI Validation" running
5. Once complete, check the PR for a comment with Recce results

## Troubleshooting

### "Recce Cloud unavailable" message

**Cause**: API key not configured or invalid

**Solution**:
- Verify `RECCE_API_KEY` secret exists in GitHub
- Check that the API key is valid in Recce Cloud
- Ensure your GitHub account has access to the Recce Cloud organization

### Workflow not running

**Cause**: Workflow file not in correct location or GitHub Actions disabled

**Solution**:
- Verify `.github/workflows/recce-ci.yml` exists
- Check repository Settings → Actions → General
- Ensure "Allow all actions and reusable workflows" is enabled

### "No baseline found" error

**Cause**: Main branch hasn't been built yet

**Solution**:
- Merge an initial commit to `main` first
- Or manually trigger the workflow on `main` branch

## What Happens in CI

1. **Checkout**: Gets the code
2. **Setup**: Installs Python, dbt, Recce
3. **Build Baseline**: Checks out `main`, runs `dbt build`
4. **Build PR**: Checks out PR branch, runs `dbt build`
5. **Recce Cloud**: Uploads artifacts and runs comparison
6. **Comment**: Posts results to PR

## Next Steps

- Review the [Recce Cloud documentation](https://docs.recce.dev)
- Customize the workflow for your needs
- Set up CD (Continuous Delivery) to update baseline automatically

---

**Need Help?** Check the [Recce documentation](https://docs.recce.dev) or reach out to your Recce Cloud admin.


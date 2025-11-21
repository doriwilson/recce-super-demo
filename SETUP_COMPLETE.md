# ✅ Training Repository Setup Complete!

Your Super Recce Training repository is now fully configured and ready for the 45-minute training session with your 3 analysts.

## What's Been Set Up

### ✅ Complete Repository Structure
- Base dbt project with Jaffle Shop models
- DuckDB configuration (no warehouse needed)
- All models properly structured (staging → intermediate → marts)

### ✅ Three Training PRs
1. **PR #1**: Incremental model filter change (`pr1-incremental-filter`)
2. **PR #2**: Model rename with breaking change (`pr2-model-rename`)
3. **PR #3**: Timestamp logic change (`pr3-timestamp-logic`)

All PR changes are in `pr-changes/` directories and documented in `.github/pull_requests/`

### ✅ Recce Cloud CI Integration
- GitHub Actions workflow configured (`.github/workflows/recce-ci.yml`)
- Automatically runs on PRs
- Setup guide included (`.github/RECCE_CLOUD_SETUP.md`)

### ✅ Helper Scripts
- `scripts/setup.sh`: Automated setup (executable)
- `scripts/switch-pr.sh`: Quick PR switching (executable)

### ✅ Comprehensive Documentation
- `README.md`: Complete overview
- `QUICK_START.md`: 5-minute setup guide
- `REPOSITORY_SUMMARY.md`: Detailed structure explanation
- PR descriptions with validation checklists
- Validation checklist template

## Next Steps for You

### 1. Set Up Recce Cloud CI (5 minutes)

Since you mentioned you already have Recce Cloud access:

1. **Get your API key**:
   - Go to https://cloud.recce.dev
   - Navigate to Settings → API Keys
   - Create a new API key for "GitHub Actions CI"

2. **Add to GitHub Secrets**:
   - Go to your repository on GitHub
   - Settings → Secrets and variables → Actions
   - Add secret: `RECCE_API_KEY` with your API key value

3. **Test the workflow**:
   - Create a test PR or use one of the training PRs
   - Check the Actions tab to see it run
   - Verify results are posted to the PR

See `.github/RECCE_CLOUD_SETUP.md` for detailed instructions.

### 2. Create the PR Branches (10 minutes)

The PR changes are ready in `pr-changes/` directories. You need to create the branches:

```bash
# Make sure you're on main branch with all base files committed
git checkout main
git add .
git commit -m "Initial commit: base training repository"

# Create PR #1
git checkout -b pr1-incremental-filter
cp pr-changes/pr1/orders.sql models/marts/orders.sql
git add models/marts/orders.sql
git commit -m "Convert orders to incremental model with expanded status filter"

# Create PR #2
git checkout main
git checkout -b pr2-model-rename
git mv models/staging/stg_orders.sql models/staging/staging_orders.sql
cp pr-changes/pr2/staging_orders.sql models/staging/staging_orders.sql
# Note: Intentionally do NOT update models/marts/orders.sql
git add .
git commit -m "Rename stg_orders to staging_orders (intentional breaking change)"

# Create PR #3
git checkout main
git checkout -b pr3-timestamp-logic
cp pr-changes/pr3/stg_orders.sql models/staging/stg_orders.sql
git add models/staging/stg_orders.sql
git commit -m "Convert order_date from EST to UTC"
```

Or use the helper script after creating branches:
```bash
./scripts/switch-pr.sh 1  # Test PR #1
```

### 3. Test the Setup (5 minutes)

```bash
# Run setup script
./scripts/setup.sh

# Verify it works
dbt build  # Should complete in <30 seconds

# Test a PR
git checkout pr1-incremental-filter
dbt build
recce run  # Should show Value Diff and Profile Diff
```

### 4. Prepare for Training

1. **Review the PRs yourself** to familiarize yourself with the changes
2. **Test Recce Cloud CI** by creating a test PR
3. **Print or share** the validation checklist (`.github/validation-checklist.md`)
4. **Have the Quick Start guide ready** (`QUICK_START.md`)

## Training Flow

### Pre-Training Setup (Analysts)
- Each analyst clones the repo
- Runs `./scripts/setup.sh`
- Verifies `dbt build` works

### During Training (45 minutes)
1. **PR #1** (15 min): Incremental model validation
2. **PR #2** (15 min): Breaking change detection
3. **PR #3** (15 min): Timestamp validation

### Post-Training
- Analysts apply patterns to their real work
- Use validation checklist for real PRs
- Set up Recce Cloud CI for their projects

## File Locations Reference

| What You Need | Where to Find It |
|--------------|------------------|
| Setup instructions | `QUICK_START.md` |
| PR descriptions | `.github/pull_requests/` |
| Validation checklist | `.github/validation-checklist.md` |
| Recce Cloud setup | `.github/RECCE_CLOUD_SETUP.md` |
| PR branch creation | `.github/PR_SETUP.md` |
| Complete overview | `README.md` |
| Repository structure | `REPOSITORY_SUMMARY.md` |

## Troubleshooting

### "Profile 'super' not found"
- Ensure `profiles.yml` exists (copy from `profiles.yml.example`)
- Check it's in `~/.dbt/` or project root

### "Database file is locked"
- Close any other connections to `super_training.duckdb`
- Delete the file and rebuild: `rm *.duckdb && dbt build`

### "No such table: jaffle_shop.orders"
- Run `dbt seed` first to load seed data

### Recce Cloud not working in CI
- Verify `RECCE_API_KEY` secret is set in GitHub
- Check workflow logs for error messages
- See `.github/RECCE_CLOUD_SETUP.md` for troubleshooting

## Support

- **Recce Documentation**: https://docs.recce.dev
- **Recce Cloud**: https://cloud.recce.dev
- **Repository Issues**: Check documentation files first

---

**You're all set!** The repository is ready for training. Just complete the "Next Steps" above and you'll be ready to teach your analysts how to use Recce effectively.

Good luck with the training! 🚀


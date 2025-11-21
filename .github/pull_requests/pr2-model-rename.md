# PR #2: Model Rename with Breaking Change

**Branch**: `pr2-model-rename`  
**Business Scenario**: Assessing downstream impact of renaming models during refactoring  
**Training Focus**: Breaking Change Analysis and Column-Level Lineage

## What This PR Demonstrates

This PR simulates a refactoring scenario: you're renaming models to improve consistency (e.g., `stg_orders` → `staging_orders`). However, we've **intentionally left a breaking change** to demonstrate how Recce catches it.

### The Change

We're renaming `stg_orders` to `staging_orders` but **not updating the `ref()` call** in `models/marts/orders.sql`.

**Before**: `stg_orders` model exists, referenced by `orders`  
**After**: `staging_orders` model exists, but `orders` still references `stg_orders` ❌

### Why This Matters

Model renames are common during refactoring, but missing a `ref()` update can:
- Break production silently (if tests don't catch it)
- Cause downstream models to fail
- Create confusion about which model is actually being used
- Lead to data inconsistencies

## Expected Recce Findings

When you run `recce run` comparing this PR to main, you should see:

### 1. Breaking Changes ⚠️
- **Missing Model**: `stg_orders` is referenced but doesn't exist
- **New Model**: `staging_orders` exists but isn't referenced where expected
- **Action**: This should be flagged as a breaking change

### 2. Dependency Graph
- Recce should show the broken dependency chain:
  - `orders` → `stg_orders` (broken)
  - `orders` should reference `staging_orders` instead

### 3. Column-Level Lineage
- Should show which columns are affected by the broken reference
- Highlights downstream impact

### 4. Compilation Errors
- `dbt compile` or `dbt build` should fail with:
  ```
  Compilation Error: Node 'orders' depends on a node named 'stg_orders' which was not found
  ```

## Files Changed

1. **`models/staging/stg_orders.sql`** → **`models/staging/staging_orders.sql`**
   - Model renamed (file moved/renamed)
   - Model name in SQL changed to `staging_orders`

2. **`models/marts/orders.sql`** ❌
   - **INTENTIONALLY NOT UPDATED**: Still references `{{ ref('stg_orders') }}`
   - This is the breaking change Recce should catch

## Validation Checklist

Use this checklist when reviewing this PR:

- [ ] **Breaking Change Detected**: Recce flags the missing `stg_orders` reference
- [ ] **Dependency Analysis**: Review which models are affected
- [ ] **Fix Required**: Update `orders.sql` to use `{{ ref('staging_orders') }}`
- [ ] **Downstream Impact**: Check if any other models reference `stg_orders`
- [ ] **Compilation Check**: Verify `dbt compile` fails before fix, succeeds after

## How to Test This PR

```bash
# 1. Switch to PR branch
git checkout pr2-model-rename

# 2. Try to build (should fail)
dbt build
# Expected error: Node 'orders' depends on 'stg_orders' which was not found

# 3. Run Recce (should catch the breaking change)
recce run
# Review Breaking Changes section

# 4. Fix the issue (for training purposes)
# Edit models/marts/orders.sql:
# Change: {{ ref('stg_orders') }}
# To: {{ ref('staging_orders') }}

# 5. Verify fix
dbt build  # Should now succeed
```

## Real-World Application

In your actual project, this pattern applies when:
- Refactoring staging layer for new channels (Google → Google/Kayak/Trivago)
- Standardizing naming conventions across models
- Splitting or merging models
- Reorganizing model structure

**Key Takeaway**: Always use Recce's Breaking Change Analysis before merging refactoring PRs. It catches missing `ref()` updates that might not be caught by tests.

## The Fix

To fix this PR, update `models/marts/orders.sql`:

```sql
-- Change this:
with orders as (
    select * from {{ ref('stg_orders') }}  -- ❌ Broken
),

-- To this:
with orders as (
    select * from {{ ref('staging_orders') }}  -- ✅ Fixed
),
```

## Next Steps

After reviewing this PR:
1. Understand how Recce detects breaking changes
2. Review the dependency graph visualization
3. Move to [PR #3](./pr3-timestamp-logic.md) to see timestamp validation


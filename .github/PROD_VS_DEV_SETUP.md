# Production vs. Development Data Comparison Setup

This guide explains how to configure Recce to compare actual data between production and development environments.

## Current Setup (PR vs Main Artifacts)

**What it does:**
- Compares PR branch artifacts to main branch artifacts
- Queries database for PR branch data only
- Base data is in artifacts (schema/metadata), not in database

**Limitation:**
- Cannot compare actual data values between prod and dev
- Only compares PR branch data to main branch schema

## True Prod vs Dev Data Comparison

To compare actual data between production and development environments, you need data from both environments in the database.

### Option 1: Separate Schemas (Recommended for Training)

Use the same DuckDB file with different schemas:

```bash
# 1. Build main branch to prod schema (base/production data)
git checkout main
dbt build --target prod
# This populates the 'prod' schema in super_training.duckdb

# 2. Build PR branch to dev schema (development data)
git checkout pr1-incremental-filter
dbt build --target dev
# This populates the 'dev' schema in super_training.duckdb

# 3. Run Recce - it will query both schemas
recce server recce_state.json
```

**How Recce uses this:**
- Base artifacts point to `prod` schema
- Target artifacts point to `dev` schema
- Recce queries both schemas for actual data comparisons

### Option 2: Separate Databases (Production Setup)

In production with Snowflake:

```yaml
# profiles.yml
super:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_account
      database: ANALYTICS_DEV
      schema: DBT_DEV
    prod:
      type: snowflake
      account: your_account
      database: ANALYTICS_PROD
      schema: DBT_PROD
```

**Workflow:**
1. Generate base artifacts from prod: `dbt build --target prod`
2. Generate target artifacts from dev: `dbt build --target dev`
3. Recce connects to both databases and queries actual data

## Updating the Training Setup

To enable prod vs dev data comparison in the training repo:

1. **Build main branch to prod schema:**
   ```bash
   git checkout main
   dbt build --target prod
   # Copy artifacts to target-base/
   cp -r target/* target-base/
   ```

2. **Update state files to reference prod schema:**
   - State files should point base artifacts to `prod` schema
   - Target artifacts point to `dev` schema

3. **Participants build PR branches to dev:**
   ```bash
   git checkout pr1-incremental-filter
   dbt build --target dev
   recce server recce_state.json
   ```

## What Recce Queries

When comparing prod vs dev:

- **Schema Diff**: Compares artifacts (no database query needed)
- **Value Diff**: Queries both `prod` and `dev` schemas for row counts, aggregates
- **Profile Diff**: Queries both schemas for column distributions, min/max, nulls

## Current Training Setup

The current setup is optimized for:
- **Fast workshop setup** (no need to build main branch)
- **Schema comparisons** (artifacts are sufficient)
- **PR branch data validation** (compares PR changes to base schema)

For true prod vs dev data comparison, you'd need to:
1. Build main branch to prod schema
2. Build PR branch to dev schema
3. Update state files to reference both schemas

---

**Note**: The current setup works great for training because it focuses on schema and PR changes. For production use, you'd want the full prod vs dev data comparison setup.


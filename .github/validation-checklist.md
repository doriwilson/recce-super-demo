# Validation Checklist Template

Use this checklist before merging any PR in your dbt project. This template is based on the patterns demonstrated in the Super Recce Training repository.

## Pre-Merge Validation Checklist

### 1. Breaking Changes Review
- [ ] **Breaking Change Analysis**: Review Recce's breaking change report
  - [ ] No unexpected model deletions
  - [ ] No unexpected column deletions
  - [ ] All `ref()` calls are updated if models were renamed
  - [ ] All downstream models still compile

**How to check**: `recce run` → Review "Breaking Changes" section

### 2. Value Diff Analysis
- [ ] **Row Count Changes**: Verify row count changes are expected
  - [ ] Document why row counts changed (e.g., filter expansion)
  - [ ] Check for unexpected 0-row results
  - [ ] Verify incremental models still capture new data

- [ ] **Value Changes**: Review significant value differences
  - [ ] Threshold: Flag changes >5% for review
  - [ ] Document expected value shifts (e.g., timestamp conversions)
  - [ ] Verify aggregate calculations are correct

**How to check**: `recce run` → Review "Value Diff" section

### 3. Profile Diff Analysis
- [ ] **Column Distributions**: Check for unexpected distribution changes
  - [ ] Null percentages are reasonable
  - [ ] Unique value counts make sense
  - [ ] Min/max values are within expected ranges
  - [ ] Data types haven't changed unexpectedly

**How to check**: `recce run` → Review "Profile Diff" section

### 4. Downstream Impact
- [ ] **Dependency Graph**: Review all downstream models
  - [ ] All dependent models still build successfully
  - [ ] Column references are still valid
  - [ ] No broken `ref()` calls

**How to check**: `dbt list --select +model_name` or Recce's dependency graph

### 5. Incremental Logic (if applicable)
- [ ] **Incremental Strategy**: Verify incremental logic still works
  - [ ] Unique key is still valid
  - [ ] Filter logic doesn't exclude needed historical data
  - [ ] Incremental predicate is correct
  - [ ] Test with a small date range first

**How to check**: 
- Review incremental config in model
- Run `dbt run --select model_name --full-refresh` then `dbt run --select model_name` to test incremental

### 6. Uniqueness & Data Quality
- [ ] **Surrogate Keys**: Verify uniqueness constraints
  - [ ] Primary keys remain unique
  - [ ] Timestamp changes don't break uniqueness
  - [ ] No duplicate rows introduced

- [ ] **Data Quality Tests**: All dbt tests pass
  - [ ] `dbt test` completes successfully
  - [ ] Custom tests are still valid
  - [ ] Source freshness checks pass

**How to check**: `dbt test`

### 7. Documentation
- [ ] **Model Documentation**: Update docs if needed
  - [ ] Model descriptions reflect changes
  - [ ] Column descriptions are accurate
  - [ ] Business logic is documented

**How to check**: `dbt docs generate && dbt docs serve`

## PR-Specific Considerations

### For Incremental Model Changes (PR #1 pattern)
- [ ] Test incremental logic with both old and new filters
- [ ] Verify historical data is preserved correctly
- [ ] Check that new filter doesn't exclude needed data

### For Model Renames (PR #2 pattern)
- [ ] Search codebase for all references to old name
- [ ] Update all `ref()` calls
- [ ] Update documentation
- [ ] Check for hardcoded model names in macros/tests

### For Timestamp/Timezone Changes (PR #3 pattern)
- [ ] Verify timezone conversion is correct
- [ ] Check that uniqueness isn't broken by timestamp changes
- [ ] Validate date ranges are still correct
- [ ] Test with edge cases (DST transitions, leap years, etc.)

## Sign-Off

- [ ] **Reviewed by**: _________________ (Data Analyst/Engineer)
- [ ] **Date**: _________________
- [ ] **Recce Report Attached**: Yes / No
- [ ] **Ready to Merge**: Yes / No

---

**Note**: This checklist should be customized for your team's specific needs and risk tolerance. Some checks may be automated in CI/CD.


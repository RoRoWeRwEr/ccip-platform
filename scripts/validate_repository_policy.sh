#!/usr/bin/env bash
set -euo pipefail

repository_root="$(git rev-parse --show-toplevel)"
cd "$repository_root"

migration_list="$(mktemp)"
trap 'rm -f "$migration_list"' EXIT
find supabase/migrations -maxdepth 1 -type f -name '*.sql' -print | sort > "$migration_list"
migration_count="$(wc -l < "$migration_list" | tr -d ' ')"
if ((migration_count == 0)); then
  echo "No migrations found" >&2
  exit 1
fi

expected=1
while IFS= read -r migration; do
  filename="$(basename "$migration")"
  if [[ ! "$filename" =~ ^([0-9]{4})_[a-z0-9]+(_[a-z0-9]+)*\.sql$ ]]; then
    echo "Invalid migration filename: $filename" >&2
    exit 1
  fi
  number=$((10#${BASH_REMATCH[1]}))
  if ((number != expected)); then
    printf 'Migration ordering error: expected %04d, found %04d\n' "$expected" "$number" >&2
    exit 1
  fi
  expected=$((expected + 1))
done < "$migration_list"

base_ref="${BASE_REF:-}"
if [[ -n "$base_ref" ]]; then
  changed_existing="$(git diff --name-only --diff-filter=MDR "$base_ref"...HEAD -- 'supabase/migrations/*.sql')"
  if [[ -n "$changed_existing" ]]; then
    echo "Merged migration files are immutable; existing migrations changed:" >&2
    printf '%s\n' "$changed_existing" | sed 's/^/  /' >&2
    exit 1
  fi

  added="$(git diff --name-only --diff-filter=A "$base_ref"...HEAD -- 'supabase/migrations/*.sql')"
  added_count="$(printf '%s\n' "$added" | sed '/^$/d' | wc -l | tr -d ' ')"
  if ((added_count > 1)); then
    echo "A PR may add only one cohesive migration" >&2
    printf '%s\n' "$added" | sed 's/^/  /' >&2
    exit 1
  fi
fi

if git grep -InE '(ANTHROPIC_API_KEY|SUPABASE_SERVICE_ROLE_KEY|DATABASE_URL)[[:space:]]*[:=][[:space:]]*[^$<{[:space:]]' -- ':!scripts/validate_repository_policy.sh'; then
  echo "Possible hardcoded secret found" >&2
  exit 1
fi

echo "Repository policy validation passed for $migration_count ordered migrations."

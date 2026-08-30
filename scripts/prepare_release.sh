#!/usr/bin/env bash

# Adapted from LoadingIndicator's release helper for this package's changelog
# format and historical version/tag state.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/prepare_release.sh [patch|minor|major|VERSION] [--dry-run] [--no-fetch]

Prepare the next package release. A real patch release asks GitHub for release
notes before changing files, commits and pushes only the root pubspec.yaml and
CHANGELOG.md, creates and pushes the version tag, and uses those notes for the
GitHub Release.
Minor, major, and explicit versions update the local root pubspec.yaml and
CHANGELOG.md.
The default bump is patch. VERSION may optionally start with "v".

Examples:
  scripts/prepare_release.sh
  scripts/prepare_release.sh minor
  scripts/prepare_release.sh 4.5.3 --dry-run
EOF
}

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

require_gh_auth() {
  command -v gh >/dev/null 2>&1 || die 'gh CLI is required to generate release notes'
  gh auth status >/dev/null 2>&1 || die 'gh CLI is not authenticated; run gh auth login first'
}

cleanup_release_notes() {
  [ -z "$release_notes_file" ] || rm -f "$release_notes_file"
}

generate_release_notes_preview() {
  local target_commit

  require_gh_auth
  target_commit=$(git rev-parse HEAD) || die 'could not determine the current commit for release notes'
  release_notes_file=$(mktemp "${TMPDIR:-/tmp}/pin-input-text-field-release-notes.XXXXXX") || \
    die 'could not create a temporary release-notes file'

  local -a gh_command=(
    api
    --method POST
    'repos/{owner}/{repo}/releases/generate-notes'
    --raw-field "tag_name=$next_version"
    --raw-field "target_commitish=$target_commit"
  )

  if [ -n "$previous_tag" ]; then
    gh_command+=(--raw-field "previous_tag_name=$previous_tag")
  fi
  gh_command+=(--jq .body)

  if ! gh "${gh_command[@]}" > "$release_notes_file"; then
    cleanup_release_notes
    release_notes_file=
    die "could not generate GitHub release notes for $next_version"
  fi
  [ -s "$release_notes_file" ] || {
    cleanup_release_notes
    release_notes_file=
    die "GitHub returned empty release notes for $next_version"
  }

  printf 'Generated GitHub release notes for %s.\n' "$next_version"
}

generate_release_notes() {
  local -a gh_command=(
    release create
    "$next_version"
    --verify-tag
    --title "$next_version"
  )

  if [ -n "$release_notes_file" ]; then
    gh_command+=(--notes-file "$release_notes_file")
  else
    gh_command+=(--generate-notes)
    if [ -n "$previous_tag" ]; then
      gh_command+=(--notes-start-tag "$previous_tag")
    fi
  fi

  printf '\nCreating GitHub Release %s with generated notes...\n' "$next_version"
  if gh "${gh_command[@]}"; then
    printf 'Created GitHub Release %s.\n' "$next_version"
  elif gh release view "$next_version" >/dev/null 2>&1; then
    printf 'GitHub Release %s already exists; continuing.\n' "$next_version"
  else
    die "could not create GitHub Release $next_version"
  fi
}

commit_and_push_release() {
  git add -- pubspec.yaml CHANGELOG.md || die 'could not stage the release files'
  git diff --cached --quiet -- pubspec.yaml && die 'the root pubspec.yaml version was not changed'
  git diff --cached --quiet -- CHANGELOG.md && die 'CHANGELOG.md was not updated'

  git commit -m "chore(release): prepare $next_version" || \
    die "could not commit the release files for $next_version"
  git push origin master || die 'could not push master to origin'

  git tag -a "$next_version" -m "Release $next_version" || \
    die "could not create tag $next_version"
  git push origin "refs/tags/$next_version" || \
    die "could not push tag $next_version to origin"
}

update_changelog() {
  local release_date temporary_changelog original_mode

  [ -f CHANGELOG.md ] || die 'CHANGELOG.md was not found at the repository root'
  release_date=$(date '+%Y/%m/%d') || die 'could not determine the release date'

  if awk -v version="$next_version" \
    'index($0, "## [" version "]") == 1 { found = 1 } END { exit !found }' \
    CHANGELOG.md; then
    die "CHANGELOG.md already contains version $next_version"
  fi

  temporary_changelog=$(mktemp "${TMPDIR:-/tmp}/pin-input-text-field-changelog.XXXXXX") || \
    die 'could not create a temporary CHANGELOG.md'
  if ! awk -v next_version="$next_version" -v release_date="$release_date" \
    -v notes_file="$release_notes_file" '
    !inserted && /^## \[[0-9]/ {
      print "## [" next_version "] - " release_date
      print ""
      if (notes_file != "") {
        while ((getline note < notes_file) > 0) print note
        close(notes_file)
      } else {
        print "* See the generated GitHub Release for detailed release notes."
      }
      print ""
      inserted = 1
    }
    { print }
    END {
      if (!inserted) exit 1
    }
  ' CHANGELOG.md > "$temporary_changelog"; then
    rm -f "$temporary_changelog"
    die 'could not add the new version to CHANGELOG.md'
  fi

  original_mode=$(stat -f '%Lp' CHANGELOG.md 2>/dev/null) || \
    original_mode=$(stat -c '%a' CHANGELOG.md)
  chmod "$original_mode" "$temporary_changelog" || die 'could not preserve CHANGELOG.md permissions'
  mv "$temporary_changelog" CHANGELOG.md || die 'could not update CHANGELOG.md'
  printf 'Updated CHANGELOG.md with %s.\n' "$next_version"
}

version_is_valid() {
  [[ "$1" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]
}

version_is_greater() {
  local left_major left_minor left_patch
  local right_major right_minor right_patch

  IFS=. read -r left_major left_minor left_patch <<< "$1"
  IFS=. read -r right_major right_minor right_patch <<< "$2"

  if [ "$left_major" -ne "$right_major" ]; then
    [ "$left_major" -gt "$right_major" ]
  elif [ "$left_minor" -ne "$right_minor" ]; then
    [ "$left_minor" -gt "$right_minor" ]
  else
    [ "$left_patch" -gt "$right_patch" ]
  fi
}

versions_are_equal() {
  ! version_is_greater "$1" "$2" && ! version_is_greater "$2" "$1"
}

tag_is_version() {
  local version="${1#v}"
  version_is_valid "$version"
}

tag_version() {
  printf '%s\n' "${1#v}"
}

tag_list_contains() {
  local candidate="$1"
  local tag

  while IFS= read -r tag; do
    [ "$tag" = "$candidate" ] && return 0
  done <<< "$tag_list"

  return 1
}

tag_is_reachable_or_equivalent() {
  local tag_commit="$1"
  local side

  if git merge-base --is-ancestor "$tag_commit" HEAD 2>/dev/null; then
    return 0
  fi

  # A release tag can point to a parallel checkout whose commits were
  # cherry-picked into the current branch. Treat that history as equivalent
  # only when the tag side has no commits left after patch-equivalence filtering.
  while IFS= read -r side; do
    [ "$side" != '<' ] || return 1
  done < <(git log --left-right --cherry-pick --format='%m' "$tag_commit...HEAD" 2>/dev/null)

  return 0
}

prefer_tag() {
  local candidate="$1"
  local current="$2"

  if [ -z "$current" ]; then
    return 0
  fi

  if [[ "$candidate" != v* && "$current" == v* ]]; then
    return 0
  fi

  return 1
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

BUMP_KIND=patch
EXPLICIT_VERSION=
DRY_RUN=0
NO_FETCH=0
release_notes_file=
trap cleanup_release_notes EXIT HUP INT TERM

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --no-fetch)
      NO_FETCH=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    patch|minor|major)
      [ -z "$EXPLICIT_VERSION" ] || die 'choose one bump type or one explicit version'
      BUMP_KIND="$1"
      ;;
    v[0-9]*|[0-9]*)
      [ -z "$EXPLICIT_VERSION" ] || die 'only one explicit version is allowed'
      EXPLICIT_VERSION="${1#v}"
      version_is_valid "$EXPLICIT_VERSION" || die "invalid version: $1"
      ;;
    *)
      die "unknown argument: $1 (use --help for usage)"
      ;;
  esac
  shift
done

AUTO_RELEASE=0
if [ "$BUMP_KIND" = patch ] && [ -z "$EXPLICIT_VERSION" ]; then
  AUTO_RELEASE=1
fi

[ -f pubspec.yaml ] || die 'pubspec.yaml was not found at the repository root'
git rev-parse --show-toplevel >/dev/null 2>&1 || die 'this script must run inside a Git repository'

if [ "$AUTO_RELEASE" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
  current_branch=$(git symbolic-ref --quiet --short HEAD) || \
    die 'patch releases must run from a named branch'
  [ "$current_branch" = master ] || die "patch releases must run from master, not $current_branch"

  git config --get remote.origin.url >/dev/null 2>&1 || \
    die 'an origin remote is required for an automatic patch release'

  [ -z "$(git status --porcelain)" ] || \
    die 'the working tree must be clean before an automatic patch release'

  require_gh_auth
fi

if ! git diff --quiet HEAD -- pubspec.yaml; then
  die 'pubspec.yaml already has local changes; review or commit them before running this script'
fi

if ! git diff --quiet HEAD -- CHANGELOG.md; then
  die 'CHANGELOG.md already has local changes; review or commit them before running this script'
fi

if [ "$NO_FETCH" -eq 0 ] && git config --get remote.origin.url >/dev/null 2>&1; then
  if [ "$AUTO_RELEASE" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
    git fetch origin master --tags || die 'could not refresh origin/master and tags; use --no-fetch only if the local refs are current'
  else
    git fetch --tags origin || die 'could not refresh origin tags; use --no-fetch only if the local tags are current'
  fi
fi

if [ "$NO_FETCH" -eq 0 ] && git config --get remote.origin.url >/dev/null 2>&1; then
  # Fetching does not prune local tags deleted from the remote. Read the
  # remote refs directly so deleted releases cannot affect the next version.
  tag_list=$(git ls-remote --tags --refs origin | \
    sed -n 's#^[^[:space:]]*[[:space:]]refs/tags/##p') || \
    die 'could not read origin tags; use --no-fetch only if the local tags are current'
else
  tag_list=$(git tag --list)
fi

if [ "$AUTO_RELEASE" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
  origin_master_commit=$(git rev-parse --verify refs/remotes/origin/master^{commit} 2>/dev/null) || \
    die 'origin/master was not found; fetch it before running an automatic patch release'
  [ "$(git rev-parse HEAD)" = "$origin_master_commit" ] || \
    die 'local master must match origin/master before an automatic patch release'
fi

package_version=$(sed -n 's/^version:[[:space:]]*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)[[:space:]]*$/\1/p' pubspec.yaml | head -n 1)
version_is_valid "$package_version" || die 'could not read a stable three-part version from pubspec.yaml'

latest_tag=
latest_version=
reachable_tag=
reachable_version=

while IFS= read -r tag; do
  tag_is_version "$tag" || continue
  version=$(tag_version "$tag")

  if [ -z "$latest_version" ] || version_is_greater "$version" "$latest_version" || \
    { versions_are_equal "$version" "$latest_version" && prefer_tag "$tag" "$latest_tag"; }; then
    latest_tag="$tag"
    latest_version="$version"
  fi

  tag_commit=$(git rev-parse --verify "${tag}^{commit}" 2>/dev/null) || continue
  if tag_is_reachable_or_equivalent "$tag_commit"; then
    if [ -z "$reachable_version" ] || version_is_greater "$version" "$reachable_version" || \
      { versions_are_equal "$version" "$reachable_version" && prefer_tag "$tag" "$reachable_tag"; }; then
      reachable_tag="$tag"
      reachable_version="$version"
    fi
  fi
done <<< "$tag_list"

if [ -n "$latest_version" ] && [ "$latest_version" != "$reachable_version" ]; then
  if version_is_greater "$package_version" "$latest_version"; then
    die "latest tag $latest_tag ($latest_version) is not reachable from HEAD or represented by cherry-picked commits. Create a reviewed reachable v$package_version baseline tag, or repair the tag history, before releasing"
  fi
  die "latest tag $latest_tag ($latest_version) is not reachable from HEAD or represented by cherry-picked commits; latest supported tag is ${reachable_tag:-none}. Update the checkout or repair the tag history before releasing"
fi

previous_tag="$reachable_tag"
base_version="$package_version"
if [ -n "$reachable_version" ] && version_is_greater "$reachable_version" "$base_version"; then
  base_version="$reachable_version"
fi
if [ -n "$reachable_version" ] && version_is_greater "$package_version" "$reachable_version"; then
  printf 'Notice: pubspec.yaml version %s is newer than the latest reachable tag %s; using pubspec.yaml as the bump base.\n' \
    "$package_version" "$reachable_tag" >&2
fi

if [ -n "$EXPLICIT_VERSION" ]; then
  next_version="$EXPLICIT_VERSION"
else
  IFS=. read -r base_major base_minor base_patch <<< "$base_version"
  case "$BUMP_KIND" in
    major)
      next_version="$((base_major + 1)).0.0"
      ;;
    minor)
      next_version="${base_major}.$((base_minor + 1)).0"
      ;;
    patch)
      next_version="${base_major}.${base_minor}.$((base_patch + 1))"
      ;;
  esac
fi

version_is_greater "$next_version" "$package_version" || \
  die "next version $next_version must be greater than pubspec.yaml version $package_version"

if [ -n "$latest_version" ]; then
  version_is_greater "$next_version" "$latest_version" || \
    die "next version $next_version must be greater than latest tag $latest_tag"
fi

if [ "$AUTO_RELEASE" -eq 1 ] && \
  { tag_list_contains "$next_version" || tag_list_contains "v$next_version"; }; then
  die "tag $next_version or v$next_version already exists"
fi

if [ "$AUTO_RELEASE" -eq 1 ]; then
  # Generate the notes before the release-preparation commit changes HEAD.
  generate_release_notes_preview
fi

printf 'Previous reachable release: %s\n' "${previous_tag:-none}"
printf 'Current package version:   %s\n' "$package_version"
printf 'Next package version:      %s\n' "$next_version"

if [ "$DRY_RUN" -eq 1 ]; then
  printf 'Dry run: pubspec.yaml and CHANGELOG.md were not changed.\n'
else
  update_changelog
  temporary_pubspec=$(mktemp "${TMPDIR:-/tmp}/pin-input-text-field-pubspec.XXXXXX")
  original_mode=$(stat -f '%Lp' pubspec.yaml 2>/dev/null) || original_mode=$(stat -c '%a' pubspec.yaml)
  cleanup() {
    rm -f "$temporary_pubspec"
    cleanup_release_notes
  }
  trap cleanup EXIT HUP INT TERM

  awk -v next_version="$next_version" '
    /^version:[[:space:]]*/ && !changed {
      print "version: " next_version
      changed = 1
      next
    }
    { print }
    END {
      if (!changed) exit 1
    }
  ' pubspec.yaml > "$temporary_pubspec" || die 'could not update the version line in pubspec.yaml'

  chmod "$original_mode" "$temporary_pubspec"
  mv "$temporary_pubspec" pubspec.yaml
  printf 'Updated pubspec.yaml to %s.\n' "$next_version"
fi

if [ "$AUTO_RELEASE" -eq 1 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '\nDry run: would commit pubspec.yaml and CHANGELOG.md, push master, create and push tag %s, and generate its GitHub release notes.\n' "$next_version"
  else
    commit_and_push_release
    generate_release_notes
  fi
elif [ -n "$previous_tag" ]; then
  printf '\nUse this previous tag for generated release notes:\n'
  printf '  gh release create %s --verify-tag --generate-notes --notes-start-tag %s --title %s\n' \
    "$next_version" "$previous_tag" "$next_version"
fi

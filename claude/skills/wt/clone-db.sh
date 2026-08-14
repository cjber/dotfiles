#!/usr/bin/env bash
# Give a new worktree its own Postgres database, cloned from the one the main
# checkout uses, and point the worktree's .env at it.
#
# Why clone rather than share: a worktree runs migrations, `sift check --tests`
# and a dev server against whatever DATABASE_URL it inherits. Sharing one
# database means an `alembic upgrade` in one worktree silently re-shapes every
# other worktree's schema, and a truncating test wipes data another branch is
# mid-way through debugging. Both have happened.
#
# Why clone rather than create-empty-and-migrate: `createdb -T` is a filesystem
# copy, so it is near-instant and, more importantly, carries the seeded rows a
# local checkout needs to be useful at all.
#
# Every database this creates is named `wt_<feature>`. That prefix is the
# contract prune.sh drops against - nothing without it is ever touched.
#
# Usage: clone-db.sh <worktree-path> <feature>
set -eu

WT=${1:?worktree path required}
FEATURE=${2:?feature name required}
ENV_FILE="$WT/.env"

[ -f "$ENV_FILE" ] || { echo "db: no .env in worktree — skipping clone"; exit 0; }

SOURCE_URL=$(sed -n 's/^DATABASE_URL=//p' "$ENV_FILE" | head -1)
[ -n "$SOURCE_URL" ] || { echo "db: .env has no DATABASE_URL — skipping clone"; exit 0; }

# Only ever clone a local database. A DATABASE_URL pointing at a remote host is
# either Cloud SQL or a shared staging box; cloning there would create a real
# database on infrastructure this script has no business writing to.
case "$SOURCE_URL" in
    *@localhost:*|*@127.0.0.1:*) ;;
    *) echo "db: DATABASE_URL is not local — refusing to clone"; exit 0 ;;
esac

SOURCE_DB=${SOURCE_URL##*/}
SOURCE_DB=${SOURCE_DB%%\?*}

# Postgres caps identifiers at 63 bytes. Truncate the feature half, never the
# `wt_` prefix, so a long feature name cannot produce a database prune.sh
# declines to recognise.
SLUG=$(printf '%s' "$FEATURE" | tr -c 'a-zA-Z0-9' '_' | tr 'A-Z' 'a-z' | cut -c1-59)
TARGET_DB="wt_$SLUG"

if [ "$SOURCE_DB" = "$TARGET_DB" ]; then
    echo "db: already on $TARGET_DB"
    exit 0
fi

PSQL_BASE=${SOURCE_URL%/*}

if psql "$PSQL_BASE/postgres" -tAc "select 1 from pg_database where datname = '$TARGET_DB'" 2>/dev/null | grep -q 1; then
    echo "db: reusing existing $TARGET_DB"
else
    # `createdb -T` needs the template to have no other sessions. A running dev
    # server or open psql in the main checkout will hold one. Say so plainly and
    # leave .env alone rather than terminating someone's connection - the
    # worktree still works, it just shares a database until they retry.
    # Driven through the URL rather than `createdb`, whose host/port/user would
    # come from PG* environment variables and could target a different server
    # than the one DATABASE_URL names.
    if ! psql "$PSQL_BASE/postgres" -q -c "CREATE DATABASE \"$TARGET_DB\" TEMPLATE \"$SOURCE_DB\"" 2>/tmp/wt-clone-db.err; then
        echo "db: clone of $SOURCE_DB failed — worktree will share it" >&2
        sed 's/^/db: /' /tmp/wt-clone-db.err >&2
        rm -f /tmp/wt-clone-db.err
        exit 0
    fi
    rm -f /tmp/wt-clone-db.err
    echo "db: cloned $SOURCE_DB -> $TARGET_DB"
fi

# Rewrite in place. DBOS derives its own `<db>_dbos` database from this value, and
# tests/migrations derives `<db>_migrations`, so neither needs a separate edit.
TMP=$(mktemp)
sed "s|^DATABASE_URL=.*|DATABASE_URL=$PSQL_BASE/$TARGET_DB|" "$ENV_FILE" > "$TMP"
cat "$TMP" > "$ENV_FILE"
rm -f "$TMP"
echo "db: worktree .env now points at $TARGET_DB"

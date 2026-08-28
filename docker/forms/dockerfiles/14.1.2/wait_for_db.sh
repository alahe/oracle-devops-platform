#!/bin/bash
# Wait for Database readiness using WLST dbping or simple TCP/port check
if [ $# -lt 4 ]; then
  echo "Usage: wait_for_db.sh <oracle_home> <host> <port> <service>"
  exit 1
fi

ORACLE_HOME=$1
DB_HOST=$2
DB_PORT=$3
DB_SERVICE=$4

echo "⏳ Waiting for Database at ${DB_HOST}:${DB_PORT}/${DB_SERVICE}..."
MAX_WAIT=20
COUNT=0
until nc -z -w 2 "$DB_HOST" "$DB_PORT" 2>/dev/null || (exec 3<>/dev/tcp/"$DB_HOST"/"$DB_PORT") 2>/dev/null; do
  COUNT=$((COUNT + 5))
  if [ $COUNT -ge $MAX_WAIT ]; then
    echo "⚠️  Database check reached timeout (${MAX_WAIT}s). Continuing startup..."
    break
  fi
  echo "   ... Database listener not ready yet. Retrying in 5 seconds..."
  sleep 5
done
echo "✅ Database listener check complete!"

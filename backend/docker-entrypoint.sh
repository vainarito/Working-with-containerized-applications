#!/bin/sh

set -e
echo "Waiting for MySQL at ${MYSQL_HOST:-mysql}:${MYSQL_PORT:-3306}..."

until python - <<'PYCODE'
import os, sys, pymysql

host = os.environ.get("MYSQL_HOST", "mysql")
port = int(os.environ.get("MYSQL_PORT", "3306"))
user = os.environ.get("MYSQL_USER", "root")
password = os.environ.get("MYSQL_PASSWORD", "secret")
db = os.environ.get("MYSQL_DB", "tasks_db")

try:
    conn = pymysql.connect(host=host, port=port, user=user, password=password, database=db)
except Exception as e:
    print(f"FAILED to connect to MySQL: {e}")
    sys.exit(1)
else:
    conn.close()
    print("MySQL connection succesful!")
    sys.exit(0)
PYCODE
do
    echo "Retrying in 2 seconds..."
    sleep 2
done

echo "MySQL is ready. Starting the application..."

exec "$@"
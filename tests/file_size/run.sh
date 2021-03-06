#!/bin/sh

set -eu

run_sql "drop database if exists file_size"
run_sql "create database file_size"
export DUMPLING_TEST_DATABASE=file_size
run_sql "create table t (a varchar(255))"

chars_20="1111_0000_1111_0000_"

# insert 100 records, each occupies 20 bytes
i=0; while [ $i -lt 100 ]; do
  run_sql "insert into t values (\"$chars_20\")"
  i=$(( i + 1 ))
done

# dumping with file size = 200 bytes
run_dumpling -F 200

# the dumping result is expected to be:
# 10 files for insertion(each conatins 10 records / 200 bytes)
file_num=$(find "$DUMPLING_OUTPUT_DIR" -maxdepth 1 -iname "file_size.t.*.sql" | wc -l)
if [ "$file_num" -ne 10 ]; then
  echo "obtain file number: $file_num, but expect: 10" && exit 1
fi

total_lines=$(find "$DUMPLING_OUTPUT_DIR" -maxdepth 1 -iname "file_size.t.*.sql" -print0 \
 | xargs -0 cat | grep "$chars_20" -c)
if [ ! "$total_lines" = 100 ]; then
  echo "obtain record number: $total_lines, but expect: 100" && exit 1
fi

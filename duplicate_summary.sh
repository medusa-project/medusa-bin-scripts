#!/bin/bash

TMP_DIR=/media/medusa/tmp
ALL_FILES_CSV=$TMP_DIR/all_files.csv
DUPS_CSV=$TMP_DIR/dups.csv
DUPS_SQLITE=$TMP_DIR/dups.sqlite3

export PGDATABASE=medusa
export PGUSER=medusa
export PGHOST=medusa-db-prod.library.illinois.edu

echo "Password for user $PGUSER and database $PGDATABASE at $PGHOST"
read -s PGPASSWORD
export PGPASSWORD

echo "Selecting all files"
psql -c "COPY (SELECT * FROM view_cfs_files_summary) TO STDOUT (FORMAT CSV)" > $ALL_FILES_CSV
#psql -c "COPY (SELECT * FROM view_cfs_files_summary where collection_id=162) TO STDOUT (FORMAT CSV)" > $ALL_FILES_CSV

echo "Selecting duplicate files"
psql -c "COPY (SELECT * FROM view_md5_duplicates) TO STDOUT (FORMAT CSV)" > $DUPS_CSV

echo "Creating sqlite database $DUPS_SQLITE"
rm -f $DUPS_SQLITE
sqlite3 $DUPS_SQLITE <<EOF
CREATE TABLE duplicates (md5_sum CHAR, cfs_file_id BIGINT PRIMARY KEY, cfs_directory_id BIGINT, file_group_id INTEGER, collection_id INTEGER, repository_id INTEGER, uuid CHAR, name CHAR, relative_path CHAR, content_type CHAR, mtime DATETIME, size DECIMAL);

CREATE TABLE all_files (md5_sum CHAR, cfs_file_id BIGINT PRIMARY KEY, cfs_directory_id BIGINT, file_group_id INTEGER, collection_id INTEGER, repository_id INTEGER, uuid CHAR, name CHAR, relative_path CHAR, content_type CHAR, mtime DATETIME, size DECIMAL);

.mode csv
.import $ALL_FILES_CSV all_files
.import $DUPS_CSV duplicates

CREATE INDEX idx_cfs_file_id ON duplicates (cfs_file_id);
CREATE INDEX idx_cfs_directory_id ON duplicates (cfs_directory_id);
CREATE INDEX idx_md5_sum ON duplicates (md5_sum);
CREATE INDEX idx_file_group_id ON duplicates (file_group_id);
CREATE INDEX idx_collection_id ON duplicates (collection_id);
CREATE INDEX idx_repository_id ON duplicates (repository_id);
CREATE INDEX idx_content_type ON duplicates (content_type);
CREATE INDEX idx_mtime ON duplicates (mtime);
CREATE INDEX idx_name ON duplicates (name);

CREATE INDEX idx_all_cfs_file_id ON all_files (cfs_file_id);
CREATE INDEX idx_all_cfs_directory_id ON all_files (cfs_directory_id);
CREATE INDEX idx_all_md5_sum ON all_files (md5_sum);
CREATE INDEX idx_all_file_group_id ON all_files (file_group_id);
CREATE INDEX idx_all_collection_id ON all_files (collection_id);
CREATE INDEX idx_all_repository_id ON all_files (repository_id);
CREATE INDEX idx_all_content_type ON all_files (content_type);
CREATE INDEX idx_all_mtime ON all_files (mtime);
CREATE INDEX idx_all_name ON all_files (name);	

EOF

echo "Removing CSV files"
#rm -f $ALL_FILES_CSV
#rm -f $DUPS_CSV

echo "Your export is in $DUPS_SQLITE."


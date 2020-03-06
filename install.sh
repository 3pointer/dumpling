#!/bin/sh

set -e

TAG="v4.0.0-beta.1"
pwd=$(pwd)

mkdir bin/

# download lightning and sync_diff_inspector
wget http://download.pingcap.org/tidb-toolkit-$TAG-linux-amd64.tar.gz -O tools.tar.gz
tar -xzvf tools.tar.gz
mv tidb-toolkit-$TAG-linux-amd64/bin/* bin/


# download pd-server
git clone -b $TAG https://github.com/pingcap/pd
cd $pwd/pd && make
cd $pwd
mv pd/bin/pd-server bin/

# download tidb-server
git clone -b $TAG https://github.com/pingcap/tidb
cd $pwd/tidb && make
cd $pwd
mv tidb/bin/tidb-server bin/

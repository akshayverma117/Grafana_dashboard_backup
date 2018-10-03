#!/bin/bash
KEY="GRAFANA_KEY"
HOST="GRAFANA HOST"
gitCredentialID="GIT_ID"
gitUrl="GIT_URL"
currentDate=`date +%d-%m-%Y`
gitCommitMessage="Grafana dashboards on $currentDate"
cd ~/tmp/
rm -rf dashboards/
mkdir dashboards
cd dashboards
git clone GIT_BUCKET_URL
git config --global user.name "USERNAME"
git config --global user.email "GIT_EMAIL_ID"
git checkout grafana-dashboards
mkdir dashboards
for dash in $(curl -k -H "Authorization: Bearer $KEY" $HOST/api/search\?query\=\& | jq -r '.[] | .uri'); do
  curl -k -H "Authorization: Bearer $KEY" $HOST/api/dashboards/$dash | sed 's/"id":[0-9]\+,/"id":null,/' | sed 's/\(.*\)}/\1,"overwrite": true}/' | jq '.dashboard' > dashboards/$(echo ${dash} |cut -d\" -f 4 |cut -d\/ -f2).json
done
commit=$(git status --porcelain)
if [[ ${commit} != '' ]]
then 
    git add . && git commit -m $gitCommitMessage
    git push origin grafana-dashboards
else 
    echo "No changes to commit"
fi

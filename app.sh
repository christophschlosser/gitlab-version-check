#!/bin/bash

GITLAB=$(curl -s -H "PRIVATE-TOKEN: $API_TOKEN" $GITLAB_URL/api/v4/version | jq .version)
if [[ $GITLAB == "null" ]]; then
  echo "Could not retrieve version from '$GITLAB_URL'. Is your API token correct?"
  exit 1
fi

ENCODED=$(echo '{"version":'$GITLAB'}' | base64 -i -)

VERSION=$(curl -s -H "Accept: image/png,image/svg+xml,image/*;q=0.8,video/*;q=0.8,*/*;q=0.5
Referer: $GITLAB_URL
DNT: 1
Host: version.gitlab.com
Accept-Language: en-us
Accept-Encoding: br, gzip, deflate
Connection: keep-alive" https://version.gitlab.com/check.svg?gitlab_info=$ENCODED)

echo $VERSION | grep -q "up-to-date1"

if [[ $? == 0 ]]; then
  echo "Up to date"
else
  echo "Sending update mail"
  echo "An update is Available for your Gitlab Instance at $GITLAB_URL." | \
             s-nail -s "Gitlab $GITLAB is out of date" \
                               -S smtp="$SMTP_SERVER" \
                               -S smtp-auth=login \
                               -S smtp-auth-user="$SMTP_USER" \
                               -S smtp-auth-password="$SMTP_PASSWORD" \
                               -S from="$SMTP_FROM" \
                               $ADDITIONAL_ARGS \
                               $RECEIVER
fi

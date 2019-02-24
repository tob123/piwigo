#/bin/bash
set -ex
docker push tob123/piwigo-staging:${VERSION}
if [[ -n $LATEST ]]; then
  docker tag tob123/piwigo-staging:${VERSION} tob123/piwigo-staging:latest
  docker push tob123/piwigo-staging:latest
fi

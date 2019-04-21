#!/bin/sh
set -ex
restore_pw_files () {
if [ ! -f ${PW_DIR}/_data/dummy.txt ]; then
  touch ${PW_DIR}/_data/dummy.txt
fi
if [ ! -f ${PW_DIR}/themes/index.php ]; then
  if [ ! -d ${PW_DIR}/themes/default ]; then
    cp -R ${PW_SRC}/themes ${PW_DIR}
  fi
fi
if [ ! -f ${PW_DIR}/plugins/index.php ]; then
  cp -R ${PW_SRC}/plugins ${PW_DIR}
fi
if [ ! -f ${PW_DIR}/galleries/index.php ]; then
  cp -R ${PW_SRC}/galleries ${PW_DIR}
fi
if [ ! -f ${PW_DIR}/local/index.php ]; then
  if [ ! -d ${PW_DIR}/local/config ]; then
    cp -R ${PW_SRC}/local ${PW_DIR}
  fi
fi
if [ ! -f ${PW_DIR}/template-extension/index.php ]; then
  cp -R ${PW_SRC}/template-extension ${PW_DIR}
fi
}
upgrade_pw_files () {
cp -R ${PW_SRC}/themes ${PW_DIR}
cp -R ${PW_SRC}/plugins ${PW_DIR}
cp -R ${PW_SRC}/local ${PW_DIR}
cp -R ${PW_SRC}/template-extension ${PW_DIR}
cp -R ${PW_SRC}/galleries ${PW_DIR}
rm /pw_built/*
}
gmap_plugin_fix () {
#workaround for google maps plugin depending on map.php in piwigo directory.
#see also here: https://github.com/modus75/piwigo-gmaps/issues/2
if [ -f ${PW_DIR}/plugins/rv_gmaps/include/functions.php ]; then
  sed -i "s/get_root_url().'map';$/get_root_url().'plugins\/rv_gmaps\/map';/" ${PW_DIR}/plugins/rv_gmaps/include/functions.php
fi
}

if [ ${RESTORE_PW_VOL} = "true" ]; then
  restore_pw_files
fi
touch /pw_built/${PW_VERS}
if [ $(ls /pw_built/ | wc -l) -gt 1 ]; then upgrade_pw_files; fi
if [ ${GMAP_PLUGIN_FIX} = "true" ]; then
  gmap_plugin_fix
fi
#protect database and other config files
chmod 700 ${PW_DIR}/local/config
if [ -f ${PW_DIR}/local/config/database.inc.php ]; then
  chmod 400 ${PW_DIR}/local/config/database.inc.php
fi

exec "$@"

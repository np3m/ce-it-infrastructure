echo "Checking for ${STORAGE_PATH}"

. dcc-environment.sh

if [ -d ${STORAGE_PATH} ] ; then
  echo "${STORAGE_PATH} already exists"
  echo "Do you want to remove this directory or keep it? Type remove or keep"
  read RESPONSE
  if test x$RESPONSE == xremove ; then
    echo "Are you sure you want to remove ${STORAGE_PATH}?"
    echo "Type remove to delete the DCC files from ${STORAGE_PATH} or anything else to exit"
    read REMOVE
    if test x$REMOVE == xremove ; then
      echo "Removing DCC storage"
      sudo rm -rf rm -rf ${STORAGE_PATH}/etc/ ${STORAGE_PATH}/usr1/ ${STORAGE_PATH}/usr2 /${STORAGE_PATH}/var/
      echo "${STORAGE_PATH}/letsencrypt has not been removed. This must be removed manually."
    else
      echo "You did not type remove. Exiting"
      kill -INT $$
    fi
  elif test x$RESPONSE == xkeep ; then
    echo "Using files from ${STORAGE_PATH}"
  else
    echo "Error: unknown response $RESPONSE"
    kill -INT $$
  fi
else
  echo "${STORAGE_PATH} not found, creating"
fi

docker swarm leave --force &>/dev/null || true

docker image inspect np3m/dcc-base:3.3.0 &>/dev/null
RET=${?}

trap 'trap - ERR; kill -INT $$' ERR

set -o pipefail

if [ ${RET} -eq 0 ] ; then
  echo "Using existing dcc-base docker image"
else
  echo "Importing dcc-base docker image"
  virt-tar-out -a dcc-syr-disk0.qcow2 / - | docker import - np3m/dcc-base:3.3.0
fi

export CERT_DIR=$(mktemp -d)
sudo chmod 700 ${CERT_DIR}
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-cert.pem ${CERT_DIR}
sudo cp -a ${APACHE_SHIBD_DIR}/shibboleth/sp-encrypt-key.pem ${CERT_DIR}
sudo chown ${USER} ${CERT_DIR}/*.pem

echo ${MYSQL_ROOT_PASSWD} > ${CERT_DIR}/mysql_root_passwd.txt
echo ${MYSQL_DOCDBRW_PASSWD} > ${CERT_DIR}/mysql_docdbrw_passwd.txt
echo ${MYSQL_DOCDBRO_PASSWD} > ${CERT_DIR}/mysql_docdbro_passwd.txt

sudo mkdir -p ${STORAGE_PATH}/etc/shibboleth

sudo cp ${APACHE_SHIBD_DIR}/shibboleth/shibboleth2.xml ${STORAGE_PATH}/etc/shibboleth/
sudo cp attribute-map.xml ${STORAGE_PATH}/etc/shibboleth/
/usr/bin/curl -O -s https://ds.incommon.org/certs/inc-md-cert.pem
/bin/chmod 644 inc-md-cert.pem
sudo cp inc-md-cert.pem ${STORAGE_PATH}/etc/shibboleth/inc-md-cert.pem
rm -f inc-md-cert.pem
sudo /bin/chmod 644 ${STORAGE_PATH}/etc/shibboleth/*

docker build --build-arg=DCC_INSTANCE=${DCC_INSTANCE} --rm -t np3m/dcc:3.3.0 .
docker build -f Dockerfile.bootstrap --rm -t np3m/dcc-bootstrap:3.3.0 .

sudo mkdir -p ${STORAGE_PATH}/usr1/www/html/DocDB
sudo mkdir -p ${STORAGE_PATH}/usr1/www/html/public
sudo mkdir -p ${STORAGE_PATH}/var/lib/mysql
sudo mkdir -p ${STORAGE_PATH}/usr2/GLIMPSE
sudo mkdir -p ${STORAGE_PATH}/var/lib/postgresql/data
sudo mkdir -p ${STORAGE_PATH}/letsencrypt/config

if [ $(uname) == "Darwin" ] ; then
  sudo chown -R ${USER} ${STORAGE_PATH}
fi

docker network rm dcc-bootstrap-network &>/dev/null || true
docker network create dcc-bootstrap-network

docker run --rm --network dcc-bootstrap-network \
  --name hydra-database \
  -v ${STORAGE_PATH}/var/lib/postgresql/data:/var/lib/postgresql/data \
  -e POSTGRES_USER=hydra \
  -e POSTGRES_PASSWORD=${HYDRA_PASSWD} \
  -e POSTGRES_DB=hydra \
  -d postgres:9.6

docker run -it --rm \
  --network dcc-bootstrap-network \
  np3m/wait-port:0.2.6 \
  wait-port hydra-database:5432

export DSN="postgres://hydra:${HYDRA_PASSWD}@hydra-database:5432/hydra?sslmode=disable"

docker run -it --rm \
  --network dcc-bootstrap-network \
  oryd/hydra:v1.0.8 \
  migrate sql --yes $DSN

docker run -d --rm \
  --network dcc-bootstrap-network \
  --name hydra-bootstrap-server \
  -e SECRETS_SYSTEM=${SECRETS_SYSTEM} \
  -e DSN=$DSN \
  -e URLS_SELF_ISSUER=https://${DCC_INSTANCE}/oauth/ \
  -e URLS_CONSENT=https://${DCC_INSTANCE}/consent \
  -e URLS_LOGIN=https://${DCC_INSTANCE}/login \
  oryd/hydra:v1.0.8 serve all --dangerous-force-http

docker run -it --rm \
  --network dcc-bootstrap-network \
  np3m/wait-port:0.2.6 \
  wait-port hydra-bootstrap-server:4445

docker run -it --rm \
  --network dcc-bootstrap-network \
  np3m/wait-port:0.2.6 \
  wait-port hydra-bootstrap-server:4444

docker run --rm -it \
  --network dcc-bootstrap-network \
  oryd/hydra:v1.0.8 \
  clients create \
    --endpoint http://hydra-bootstrap-server:4445 \
    --callbacks https://${DCC_INSTANCE}/rest-dcc/callback \
    --id dcc-rest-api \
    --secret ${DCC_REST_SECRET} \
    --grant-types authorization_code,refresh_token \
    --response-types token,code \
    --scope openid,offline \
    --token-endpoint-auth-method client_secret_basic

docker stop hydra-bootstrap-server
docker stop hydra-database
docker network rm dcc-bootstrap-network

trap - ERR

#!/bin/bash

set -euo pipefail

command -v swagger >/dev/null 2>&1 || {
  echo >&2 "command 'swagger' not installed. see: https://github.com/go-swagger/go-swagger for installation"
  exit 1
}

command -v openapi >/dev/null 2>&1 || {
  echo >&2 "command 'openapi' not installed. see: https://www.npmjs.com/package/openapi-client for installation"
  exit 1
}

command -v swagger-codegen 2>&1 || {
  echo >&2 "command 'swagger-codegen' not installed. see: https://github.com/swagger-api/swagger-codegen for installation"
  exit 1
}

command -v openapi-generator-cli 2>&1 || {
  echo >&2 "command 'openapi-generator-cli' not installed. see: https://www.npmjs.com/package/@openapitools/openapi-generator-cli for installation"
  exit 1
}

command -v realpath 2>&1 || {
  echo >&2 "command 'realpath' not installed. see: https://www.npmjs.com/package/realpath for installation"
  exit 1
}

scriptPath=$(realpath $0)
scriptDir=$(dirname "$scriptPath")

zrokDir=$(realpath "$scriptDir/..")

zrokSpec=$(realpath "$zrokDir/specs/zrok.yml")

pythonConfig=$(realpath "$zrokDir/bin/python_config.json")

echo "...generating zrok server"
swagger generate server -P rest_model_zrok.Principal -f "$zrokSpec" -s rest_server_zrok -t "$zrokDir" -m "rest_model_zrok" --exclude-main

echo "...generating zrok client"
swagger generate client -P rest_model_zrok.Principal -f "$zrokSpec" -c rest_client_zrok -t "$zrokDir" -m "rest_model_zrok"

echo "...generating js client"
openapi -s specs/zrok.yml -o ui/src/api -l js

echo "...generating ts client"
openapi-generator-cli generate -i specs/zrok.yml -o sdk/nodejs/sdk/src/zrok/api -g typescript-node

echo "...generating python client"
swagger-codegen generate -i specs/zrok.yml -o sdk/python/sdk/zrok -c $pythonConfig -l python

git checkout rest_server_zrok/configure_zrok.go

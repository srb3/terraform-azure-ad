#!/usr/bin/env bash

curl -k -i -X POST https://admin.kongcx.ninja:8444/internal-apis/services/httpbin-service-azure/plugins \
  --data "name=application-registration" \
  --data "config.auto_approve=false" \
  --data "config.description=Uses consumer claim with various values (sub, aud, etc.) as registration id to support different flows and use cases." \
  --data "config.display_name=For Azure" \
  --data "config.show_issuer=true" \
  -H 'kong-admin-token:<kong-token>'


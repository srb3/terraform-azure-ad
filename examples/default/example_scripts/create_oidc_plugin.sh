#!/usr/bin/env bash

curl -k -i -X POST https://admin.kongcx.ninja:8444/internal-apis/services/httpbin-service-azure/plugins \
  --data name=openid-connect \
  --data config.issuer="https://login.microsoftonline.com/<tid>/v2.0" \
  --data config.auth_methods="bearer" \
  --data config.display_errors="true" \
  --data config.client_id="<client-id>" \
  --data config.client_secret="<client-secret>" \
  --data config.redirect_uri="https://example.com/api" \
  --data config.consumer_claim=aud \
  --data config.scopes="openid" \
  --data config.scopes="<id>/.default" \
  --data config.verify_parameters="false" \
  -H 'kong-admin-token:<kong-token>'

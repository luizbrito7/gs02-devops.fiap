#!/usr/bin/env bash
# Sobe SonarQube + Jenkins já configurados. Idempotente: pode rodar de novo.
# Sonar não tem config declarativa, então usa a Web API; o Jenkins usa JCasC (jenkins.yaml).
set -euo pipefail
cd "$(dirname "$0")"
source .env
S=http://localhost:9000

docker compose up -d sonarqube
until curl -s "$S/api/system/status" | grep -q '"UP"'; do sleep 5; done

# 1. Troca a senha padrão do admin (só na primeira execução)
if curl -s -u admin:admin "$S/api/authentication/validate" | grep -q '"valid":true'; then
  curl -sf -u admin:admin -X POST "$S/api/users/change_password" \
    -d login=admin -d previousPassword=admin --data-urlencode "password=$SONAR_ADMIN_PASSWORD"
fi
A="admin:$SONAR_ADMIN_PASSWORD"

# 2. Token de análise para o Jenkins (gravado no .env)
if [ -z "${SONAR_TOKEN:-}" ]; then
  SONAR_TOKEN=$(curl -sf -u "$A" -X POST "$S/api/user_tokens/generate" \
    -d name=jenkins -d type=GLOBAL_ANALYSIS_TOKEN | jq -r .token)
  echo "SONAR_TOKEN=$SONAR_TOKEN" >> .env
fi

# 3. Webhook do Quality Gate -> Jenkins (rede Docker interna é IP privado,
#    bloqueado por padrão pela sonar.validateWebhooks)
curl -sf -u "$A" -X POST "$S/api/settings/set" -d key=sonar.validateWebhooks -d value=false
if ! curl -sf -u "$A" "$S/api/webhooks/list" | grep -q sonarqube-webhook; then
  curl -sf -u "$A" -X POST "$S/api/webhooks/create" \
    -d name=jenkins -d url=http://jenkins:8080/sonarqube-webhook/ > /dev/null
fi

docker compose up -d --build --force-recreate jenkins
echo "Jenkins: $JENKINS_URL | SonarQube: ${JENKINS_URL%:8080/}:9000"

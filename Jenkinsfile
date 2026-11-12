// Pipeline DevSecOps: Testes -> SonarQube -> Quality Gate -> Build -> Trivy -> Push -> Deploy -> Validação
// Ferramentas rodam como containers via socket do Docker da VM.
// O workspace é montado no mesmo caminho dentro dos containers (coverage.xml e relatórios batem).
pipeline {
  agent any

  environment {
    REGISTRY  = credentials('ghcr') // REGISTRY_USR / REGISTRY_PSW (PAT classic, write:packages)
    IMAGE     = 'ghcr.io/luizbrito7/queimadas-api'
    TAG       = "${env.GIT_COMMIT.take(7)}"
    RUN       = "docker run --rm -v ${WORKSPACE}:${WORKSPACE} -w ${WORKSPACE}"
  }

  options {
    timeout(time: 30, unit: 'MINUTES')
    disableConcurrentBuilds()
  }

  stages {
    stage('Testes') {
      steps {
        sh '$RUN python:3.12-slim sh -c "pip install -q -r requirements-dev.txt && python -m pytest -q --cov=app --cov-report=xml --junitxml=junit.xml"'
      }
      post { always { junit 'junit.xml' } }
    }

    stage('SonarQube') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh '$RUN --network devops -e SONAR_HOST_URL -e SONAR_TOKEN=$SONAR_AUTH_TOKEN sonarsource/sonar-scanner-cli -Dsonar.projectBaseDir=$WORKSPACE -Dsonar.working.directory=$WORKSPACE/.scannerwork'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .'
      }
    }

    stage('Trivy') {
      steps {
        script {
          def trivy = '$RUN -v /var/run/docker.sock:/var/run/docker.sock -v trivy-cache:/root/.cache aquasec/trivy:0.76.2 image'
          // Relatório HIGH + CRITICAL (não bloqueia)
          sh "${trivy} --severity HIGH,CRITICAL --format table -o trivy-report.txt \$IMAGE:\$TAG"
          // Bloqueio: qualquer CRITICAL falha a pipeline
          sh "${trivy} --severity CRITICAL --exit-code 1 \$IMAGE:\$TAG"
        }
      }
      post { always { archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true } }
    }

    stage('Push') {
      steps {
        sh '''
          echo "$REGISTRY_PSW" | docker login ghcr.io -u "$REGISTRY_USR" --password-stdin
          docker push $IMAGE:$TAG
          docker push $IMAGE:latest
        '''
      }
    }

    stage('Deploy') {
      steps {
        sh 'IMAGE=$IMAGE:$TAG docker compose -p queimadas up -d --no-build'
      }
    }

    stage('Validação') {
      steps {
        sh '''
          docker run --rm --network host curlimages/curl -sf --retry 10 --retry-connrefused --retry-delay 2 http://localhost:8000/health
          docker run --rm --network host curlimages/curl -sf "http://localhost:8000/queimadas?bioma=Pantanal"
        '''
      }
    }
  }

  post {
    always { sh 'docker logout ghcr.io || true' }
  }
}

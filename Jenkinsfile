node {
    def app

    stage('Clone repository') {
        checkout scm
    }

    stage('Build distribution') {
        sh '/usr/bin/bower --allow-root install --development'
        sh 'npm install --development'
        sh '/usr/bin/grunt dist'
    }

    stage('Build image') {
        docker.withServer('unix:///var/run/docker.sock', '') {
          app = docker.build('game_server')
          app.tag("${env.BUILD_NUMBER}")
        }
    }

    stage('Run http test') {
        docker.withServer('unix:///var/run/docker.sock', '') {
            docker.image("game_server:${env.BUILD_NUMBER}").withRun('-p 6001:8000') {c ->
                sleep 3
                sh "curl http://${env.HOST_IP}:6001 &> /dev/null"
            }
         }
    }

  stage('Push image') {
        docker.withRegistry("https://${env.HOST_IP}:5000", '') {
            app.push("${env.BUILD_NUMBER}")
        }
    }

  stage('Deploy To Swarm') {
      // Check if service runs, then perform rolling upgrade, else deploy.
      if (sh(returnStatus: true, script: "docker service inspect game_server") == 0) {
          echo "Performing rolling upgrade of service."
          sh "docker service update --image ${env.HOST_IP}:5000/game_server:${env.BUILD_NUMBER} game_server"
      } else {
          echo "Performing deploy of service."
          sh "docker service create --replicas 2 -p 6001:8000 --name game_server ${env.HOST_IP}:5000/game_server:${env.BUILD_NUMBER}"
      }
  }

  stage('Verify Deployment') {
    sh "curl http://${env.HOST_IP}:6001/ &> /dev/null"
  }

}

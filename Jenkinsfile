pipeline {
    agent any

    environment {
        COMPOSE_DEV = "docker-compose --env-file env/dev.env -f docker-compose.yml -f docker-compose.dev.yml"
        COMPOSE_PROD = "docker-compose --env-file env/prod.env -f docker-compose.yml -f docker-compose.prod.yml"
    }

    stages {

        /*stage('Checkout') {
            steps {
                git branch: 'main', git 'https://github.com/ericfs1980/Jenkins_MySQL.git'
            }
        }*/

        
        /*stage('Validate Migrations') {
            steps {
                sh '''
                ${COMPOSE_DEV} down --remove-orphans || true
                ${COMPOSE_DEV} run --rm flyway validate
                '''
            }
        }*/


        
        stage('Migrate DEV') {
            steps {
                sh '''
                ${COMPOSE_DEV} down --remove-orphans || true
                ${COMPOSE_DEV} up -d mysql-dev

                echo "Aguardando MySQL subir..."
                sleep 20

                ${COMPOSE_DEV} run --rm flyway migrate
                '''
            }
        }

        stage('Validate Migrations') {
            steps {
                sh '''
                ${COMPOSE_DEV} run --rm flyway validate
                '''
            }
        }


        stage('Check Status DEV') {
            steps {
                sh '''
                ${COMPOSE_DEV} run --rm flyway info
                '''
            }
        }

        stage('Aprovação para PROD') {
            steps {
                input message: 'Deseja aplicar as migrations no ambiente PROD?'
            }
        }

        
        stage('Migrate PROD') {
            steps {
                sh '''
                ${COMPOSE_PROD} down --remove-orphans || true
                ${COMPOSE_PROD} up -d mysql-prod

                echo "Aguardando MySQL PROD subir..."
                sleep 20

                ${COMPOSE_PROD} run --rm flyway migrate
                '''
            }
        }


        stage('Check Status PROD') {
            steps {
                sh '''
                ${COMPOSE_PROD} run --rm flyway info
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executado com sucesso!'
        }
        failure {
            echo '❌ Falha no pipeline!'
        }
    }
}
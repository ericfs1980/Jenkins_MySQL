pipeline {
    agent any

    environment {
        COMPOSE_DEV = "docker-compose --env-file env/dev.env -f docker-compose.yml -f docker-compose.dev.yml"
        COMPOSE_PROD = "docker-compose --env-file env/prod.env -f docker-compose.yml -f docker-compose.prod.yml"
    }
    
    options {
        skipDefaultCheckout(true)
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

        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        
        stage('Migrate DEV') {
            steps {
                    sh '''
                    echo "Executando migrations no DEV..."
                    ${COMPOSE_DEV} run --rm --no-deps flyway migrate
                    '''
                }

        }

        stage('Validate Migrations') {
            steps {
                sh '''
                ${COMPOSE_DEV} run --rm --no-deps flyway validate
                '''
            }
        }


        stage('Check Status DEV') {
            steps {
                sh '''
                ${COMPOSE_DEV} run --rm --no-deps flyway info
                '''
            }
        }

        stage('Aprovação para PROD') {
            steps {
                input message: 'Deseja aplicar as migrations no ambiente PROD?'
            }
        }

        stage('Backup PROD') {
            steps {
                
                sh '''
                set -e
                echo "Realizando backup do banco PROD..."

                BACKUP_FILE=/backups/backup_prod_$(date +%Y%m%d_%H%M%S).sql

                docker exec jenkins_mysql-mysql-prod-1 \
                mysqldump -u root -p'$3004FedoraRoot' app_prod > $BACKUP_FILE

                echo "Backup salvo em: $BACKUP_FILE"

                echo $BACKUP_FILE > /tmp/last_backup.txt
                '''

            }
        }

        
        stage('Migrate PROD') {
            steps {
                script {
                    try{
                        sh '''
                        echo "Executando migrations no PROD..."
                        ${COMPOSE_PROD} run --rm flyway migrate
                        '''
                    } catch (Exception e) {
                        echo "Erro detectado durante migration!"
                        
                        // chama rollback direto
                        sh '''
                        echo "Executando rollback do banco PROD..."

                        BACKUP_FILE=$(cat /tmp/last_backup.txt)

                        docker exec -i jenkins_mysql-mysql-prod-1 \
                        mysql -u root -p'$3004FedoraRoot' app_prod < $BACKUP_FILE

                        echo "Rollback realizado com sucesso!!!"
                        '''

                        throw e
                    }
                }        
            }
        }


        stage ('RollBack PROD') {
            when {
                expression { currentBuild.currentResult == "FAILURE" }
            }
            steps{
                
                sh '''
                echo "Executando rollback do banco PROD..."

                BACKUP_FILE=$(cat /tmp/last_backup.txt)

                docker exec -i jenkins_mysql-mysql-prod-1 \
                mysql -u root -p'$3004FedoraRoot' app_prod < $BACKUP_FILE

                echo "Rollback realizado com sucesso!!!"
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
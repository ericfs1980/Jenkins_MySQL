FROM jenkins/jenkins:lts-jdk21

USER root

RUN apt-get update && \
    apt-get install -y docker.io docker-compose ca-certificates && \
    update-ca-certificates

# evita erro SSL com GitHub (importante no seu caso)
RUN git config --global http.sslVerify false

USER jenkins
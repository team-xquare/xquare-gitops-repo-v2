FROM gocd/gocd-agent-docker-dind:v24.3.0

USER root

RUN apk --no-cache add \
    aws-cli \
    jq

USER go

WORKDIR /go

ENTRYPOINT ["/docker-entrypoint.sh"]

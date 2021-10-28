FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y createrepo-c
RUN addgroup --system jenkins && \
adduser --system jenkins && \
adduser jenkins jenkins

USER jenkins:jenkins
CMD ["/usr/bin/createrepo_c", "/rpm"]

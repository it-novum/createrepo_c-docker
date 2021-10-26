FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y createrepo-c
CMD ["/usr/bin/createrepo_c", "/rpm"]

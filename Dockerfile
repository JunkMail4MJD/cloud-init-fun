# -------------------------------
FROM ubuntu:18.04

WORKDIR /usr/src

RUN apt-get update
RUN apt-get install cloud-utils
COPY create-cloud-init-iso.sh .
CMD [ "./create-cloud-init-iso.sh" ]

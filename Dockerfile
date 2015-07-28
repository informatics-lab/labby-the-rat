FROM node:0.10-onbuild
MAINTAINER Jacob Tomlinson <jacob.tomlinson@informaticslab.co.uk>

ENV BOTDIR /opt/labby
ENV HUBOT_PORT 8080

ADD [^.]* ${BOTDIR}/

WORKDIR ${BOTDIR}

RUN npm install

EXPOSE ${HUBOT_PORT}

CMD bin/hubot

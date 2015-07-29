FROM node:0.10-onbuild
MAINTAINER Jacob Tomlinson <jacob.tomlinson@informaticslab.co.uk>

ENV BOTDIR /opt/labby
ENV HUBOT_PORT 8080

ADD bin ${BOTDIR}/bin
ADD scripts ${BOTDIR}/scripts
ADD external-scripts.json ${BOTDIR}/external-scripts.json
ADD hubot-scripts.json ${BOTDIR}/hubot-scripts.json
ADD package.json ${BOTDIR}/package.json

WORKDIR ${BOTDIR}

RUN npm install

EXPOSE ${HUBOT_PORT}

CMD bin/hubot

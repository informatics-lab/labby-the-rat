FROM node:0.10-onbuild
MAINTAINER Jacob Tomlinson <jacob.tomlinson@informaticslab.co.uk>

ENV BOTDIR /opt/labby
ENV HUBOT_PORT 8080

RUN git clone --depth=1 https://github.com/met-office-lab/labby-the-rat.git ${BOTDIR}

WORKDIR ${BOTDIR}

RUN npm install

EXPOSE ${HUBOT_PORT}

CMD bin/hubot

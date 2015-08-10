FROM node:0.10-onbuild
MAINTAINER Jacob Tomlinson <jacob.tomlinson@informaticslab.co.uk>

ENV BOTDIR /opt/labby
ENV HUBOT_PORT 8080

# Labby can self update by doing a git pull, so it makes sense for a git clone to be in here
# rather than ADD statements.
RUN git clone --depth 1 https://github.com/met-office-lab/labby-the-rat.git ${BOTDIR}

WORKDIR ${BOTDIR}

RUN npm install

EXPOSE ${HUBOT_PORT}

CMD bin/hubot

FROM node:argon

LABEL MAINTAINER="Alexander Henderson <git@alexsguardian.net>"
LABEL SERVICES="deluge2influx.js"
LABEL REPOSITORY="https://github.com/mvantassel/deluge2influx"
LABEL VERSION="1.0.0"

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app

CMD [ "npm", "start" ]
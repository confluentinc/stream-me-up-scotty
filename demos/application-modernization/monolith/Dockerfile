FROM node:11-alpine

RUN apk --no-cache add \
      bash \
      g++ \
      ca-certificates \
      lz4-dev \
      musl-dev \
      cyrus-sasl-dev \
      openssl-dev \
      make \
      python

RUN apk add --no-cache --virtual .build-deps gcc zlib-dev libc-dev bsd-compat-headers py-setuptools bash

RUN mkdir -p /monolith
WORKDIR /monolith

COPY package.json /monolith
COPY . /monolith
RUN npm install

WORKDIR /monolith

EXPOSE 8000

CMD [ "npm", "start" ]
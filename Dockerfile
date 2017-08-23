FROM library/alpine:latest

ENTRYPOINT [ '/usr/local/bin/argbash' ]

RUN apk add --no-cache \
	bash

# Install argbash from sources
COPY    . /usr/src/argbash/
WORKDIR /usr/src/argbash/resources/
RUN     apk add --no-cache --virtual .build-dependencies \
            autoconf \
            make \
     && make install PREFIX=/usr/local \
     && apk del .build-dependencies

# This is the workspace for exec commands
WORKDIR /usr/src
VOLUME  /usr/src

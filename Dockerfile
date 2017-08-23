FROM library/alpine:latest

# The application requires bash to run.
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
WORKDIR /work
VOLUME  /work

# Run argbash with any default invocation.
ENTRYPOINT [ '/usr/local/bin/argbash' ]
CMD [ "" ]

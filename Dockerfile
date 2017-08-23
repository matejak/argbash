FROM library/alpine:latest

ENTRYPOINT [ '/usr/bin/argbash' ]

RUN apk add --no-cache \
	autoconf \
	make

# Install argbash
COPY    . /usr/share/argbash/
WORKDIR /usr/share/argbash/resources/
RUN     make install PREFIX=/usr/lib

# Make the cli executable and available on the path
RUN chmod +x /usr/share/argbash/bin/argbash \
 && ln -s /usr/share/argbash/bin/argbash /usr/bin/

# This is the workspace for exec commands
WORKDIR /usr/src
VOLUME  /usr/src

FROM library/alpine:latest

ENTRYPOINT [ '/usr/bin/argbash' ]

RUN apk add --no-cache \
	autoconf \
	make

WORKDIR /usr/share/argbash/
COPY . .
RUN cd resources \
 && make install PREFIX=/usr/lib \
 && make check

# Make the cli executable and available on the path
RUN chmod +x /usr/share/argbash/argbash \
 && ln -s /usr/share/argbash/argbash /usr/bin/

# This is the workspace for exec commands
WORKDIR /usr/src
VOLUME  /usr/src

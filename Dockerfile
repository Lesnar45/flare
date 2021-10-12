FROM node:buster

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# arFROM lsiobase/ubuntu:bionic
ENV DEBIAN_FRONTEND="noninteractive"

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"
RUN apt update -y && apt install chromium dumb-init libxss1 libgbm-dev -y
RUN apt-get install -y wget gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils

# install chrome
#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

	
# arch settings, uncomment as neccesary
ARG JACKETT_ARCH="LinuxAMDx64"
# ARG JACKETT_ARCH="LinuxARM32"
# ARG JACKETT_ARCH="LinuxARM64"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	jq \
	curl \
	libicu-dev \
	git \
	libssl1.0 \
	libxss1 \
	libgbm-dev \
	wget && \
 echo "**** install jackett ****" && \
 mkdir -p \
	/app/Jackett && \
 if [ -z ${JACKETT_RELEASE+x} ]; then \
	JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
	| jq -r .tag_name); \
 fi && \
 curl -o \
 /tmp/jacket.tar.gz -L \
	"https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.${JACKETT_ARCH}.tar.gz" && \
 tar xf \
 /tmp/jacket.tar.gz -C \
	/app/Jackett --strip-components=1 && \
 echo "**** fix for host id mapping error ****" && \
 chown -R root:root /app/Jackett && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*
	
	

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /downloads
EXPOSE $PORT

RUN apt-get install curl -y
RUN npm install -g npm@latest
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
EXPOSE 8191
ENV PUPPETEER_PRODUCT=chrome \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
RUN find /usr/lib/chromium/locales -type f ! -name 'en-US.*' -delete
RUN node -v
RUN npm -v
COPY . .
RUN npm install
#RUN node_modules/puppeteer/install.js
RUN npm run build
CMD /bin/bash -c "npm start &"

FROM lscr.io/linuxserver/jackett

# arFROM lsiobase/ubuntu:bionic
ENV DEBIAN_FRONTEND="noninteractive"


RUN apt update -y && apt install chromium-browser gettext-base dumb-init libxss1 libgbm-dev -y
RUN apt-get install -y wget gconf-service nginx libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils
#nginx
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx.conf /etc/nginx/nginx.conf

# install chrome
#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install nodejs -y
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
	wget
	

# ports and volumes
VOLUME /config /downloads
EXPOSE 9117

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

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon on;' && bash start.sh

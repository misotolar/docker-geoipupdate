FROM --platform=$BUILDPLATFORM misotolar/alpine:3.21.2

LABEL maintainer="michal@sotolar.com"

ENV GEOIPUPDATE_VERSION=7.1.0
ARG SHA256=50ccdce30dc19ddc1f9c6df1cedb40b680b0cba46327dec54cfa76ff1d75ded3
ADD https://github.com/maxmind/geoipupdate/releases/download/v${GEOIPUPDATE_VERSION}/geoipupdate_${GEOIPUPDATE_VERSION}_linux_amd64.tar.gz /tmp/geoipupdate.tar.gz

ENV GEOIPUPDATE_ACCOUNT_ID 0
ENV GEOIPUPDATE_LICENSE_KEY 000000000000
ENV GEOIPUPDATE_EDITION_IDS "GeoLite2-Country GeoLite2-City"
ENV GEOIPUPDATE_DB_DIR /usr/share/GeoIP
ENV GEOIPUPDATE_HOST updates.maxmind.com

ENV GEOIPUPDATE_SCHEDULE "0 9 * * 4"
ENV GEOIPUPDATE_XTABLES_SCHEDULE "5 9 * * 4"

RUN set -ex; \
    apk add --no-cache --upgrade \
        ca-certificates \
        curl \
        gettext-envsubst \
        libintl \
        perl-net-cidr-lite \
        perl-text-csv_xs \
        unzip \
    ; \
    echo "$SHA256  /tmp/geoipupdate.tar.gz" | sha256sum -c -; \
    tar --extract \
        --file=/tmp/geoipupdate.tar.gz \
        --directory=/usr/local/bin \
        --strip-components=1 \
        geoipupdate_${GEOIPUPDATE_VERSION}_linux_amd64/geoipupdate; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY resources/xtables/xt-build.pl /usr/local/bin/xt-build.pl
COPY resources/xtables/xt-update.sh /usr/local/bin/xt-update.sh
COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY resources/GeoIP.conf /etc/GeoIP.conf.docker

VOLUME /usr/share/GeoIP /usr/share/xt_geoip

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD ["crond", "-f"]

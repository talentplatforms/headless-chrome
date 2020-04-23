# load all the chromedriver stuff
FROM debian:buster-slim as chromedriver
ENV PACK_CORE="curl unzip"

RUN apt-get update \
  && apt-get install -fqq \
  ${PACK_CORE} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ARG CHROME_VERSION

RUN curl "https://chromedriver.storage.googleapis.com/${CHROME_VERSION}/chromedriver_linux64.zip" -o /tmp/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin \
  && chmod +x /usr/local/bin/chromedriver

# load chrome
FROM debian:buster-slim as chrome

ENV PACK_CORE="curl build-essential"

RUN apt-get update \
  && apt-get install -fqq \
  ${PACK_CORE} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -fqq \
  google-chrome-stable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

# use the step before to get started
FROM chrome as final

COPY --from=chromedriver /usr/local/bin/chromedriver /usr/local/bin/chromedriver

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG SVC_VERSION="${VCS_REF}"
ARG SVC_DESCRIPTION

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Territory Embrace | Talentplatforms" \
  org.label-schema.vcs-url="${VCS_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.name="headless-chrome" \
  org.label-schema.version="${SVC_VERSION}" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.description="an opinionated headless-chrome"

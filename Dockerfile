FROM debian:jessie
MAINTAINER Jan Garaj info@monitoringartist.com

### GRAFANA_VERSION=latest = nightly build
ENV \
  GRAFANA_VERSION=latest \
  GF_PLUGIN_DIR=/grafana-plugins \
  GF_PATHS_LOGS=/var/log/grafana \
  GF_PATHS_DATA=/var/lib/grafana \
  UPGRADEALL=true

COPY ./run.sh /run.sh

RUN \
  apt-get update && \
  apt-get -y --force-yes --no-install-recommends install libfontconfig curl ca-certificates git jq && \
  curl https://grafanarel.s3.amazonaws.com/builds/grafana_${GRAFANA_VERSION}_amd64.deb > /tmp/grafana.deb && \
  dpkg -i /tmp/grafana.deb && \
  rm -f /tmp/grafana.deb

RUN  curl -L https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 > /usr/sbin/gosu && \
  chmod +x /usr/sbin/gosu

RUN \
  for plugin in $(curl -s https://grafana.net/api/plugins?orderBy=name | jq '.items[] | select(.internal=='false') | .slug' | tr -d '"'); \
    do rc=1;count=0; while [ $rc -ne 0 ] && [ $count -lt 5 ]; do grafana-cli --pluginsDir "${GF_PLUGIN_DIR}" plugins install $plugin;rc=$?;count=$(( count+1 )); done; done
  ### branding && \
RUN sed -i 's#<title>Grafana</title>#<title>Grafana XXL</title>#g' /usr/share/grafana/public/views/index.html && \
  sed -i 's#<title>Grafana</title>#<title>Grafana XXL</title>#g' /usr/share/grafana/public/views/500.html && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/app_bundle.js && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/boot.js && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/boot.*.js && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/core/components/navbar/navbar.html && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/core/partials.js && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/partials/signup_step2.html && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/partials/signup_invited.html && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/partials/signup_invited.html && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/partials/login.html && \
  sed -i 's#icon-gf-grafana_wordmark"></i>#icon-gf-grafana_wordmark"> XXL</i>#g' /usr/share/grafana/public/app/partials/reset_password.html && \   
  chmod +x /run.sh && \
  mkdir -p /usr/share/grafana/.aws/ && \
  touch /usr/share/grafana/.aws/credentials && \
  apt-get remove -y --force-yes curl git jq && \
  apt-get autoremove -y --force-yes && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*  

VOLUME ["/var/lib/grafana", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000

ENTRYPOINT ["/run.sh"]

FROM alpine:3.3

#https://docs.syncthing.net/users/firewall.html
EXPOSE 8384 22000 21027/udp

RUN adduser -D user

ENV STNOUPGRADE true

# http://pool.sks-keyservers.net/pks/lookup?op=vindex&search=Syncthing+Release+Management&fingerprint=on
# gpg: key 00654A3E: public key "Syncthing Release Management <release@syncthing.net>" imported
ENV SYNCTHING_GPG_KEY 37C84554E7E0A261E4F76E1ED26E6ED000654A3E

# https://github.com/syncthing/syncthing/releases
ENV SYNCTHING_VERSION v0.14.9

# Stuck behind a firewall?
#ENV KEYSERVER hkp://hkps.pool.sks-keyservers.net:80
ENV KEYSERVER ha.pool.sks-keyservers.net

RUN set -x \
  && apk --no-cache --virtual .temp-deps add gnupg ca-certificates \
  && tarball="syncthing-linux-amd64-${SYNCTHING_VERSION}.tar.gz" \
  && URL="https://github.com/syncthing/syncthing/releases/download/${SYNCTHING_VERSION}" \
  && wget "${URL}/${tarball}" "${URL}/sha1sum.txt.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ${KEYSERVER} --recv-keys "${SYNCTHING_GPG_KEY}" \
  && gpg --batch --decrypt --output sha1sum.txt sha1sum.txt.asc \
  && grep -E " ${tarball}\$" sha1sum.txt | sha1sum -c - \
  && dir="$(basename "$tarball" .tar.gz)" \
  && bin="$dir/syncthing" \
  && tar -xvzf "$tarball" "$bin" \
  && mv "$bin" /usr/local/bin/syncthing \
  && rm -r "${dir}" "${tarball}" "${GNUPGHOME}" sha1sum.txt sha1sum.txt.asc \
  && apk del .temp-deps

USER user
#Something odd happening on rancherOS 0.5 with Docker 1.11.2 build b9f10c9
#if docker run --user "$(id -u):$(id -g)" flag is set $HOME is set to "/" not "/home/user"
ENV HOME /home/user
CMD ["syncthing"]

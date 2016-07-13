FROM alpine:3.3

RUN adduser -D user

# gpg: key 00654A3E: public key "Syncthing Release Management <release@syncthing.net>" imported
ENV SYNCTHING_GPG_KEY 37C84554E7E0A261E4F76E1ED26E6ED000654A3E
ENV SYNCTHING_VERSION v0.14.0-beta.1

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
CMD ["syncthing"]

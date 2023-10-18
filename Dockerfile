FROM homebrew/brew:3.6.21

ENV HOMEBREW_NO_ANALYTICS=1
ENV HOMEBREW_NO_AUTO_UPDATE=1

RUN set -eux; \
    \
    brew developer on

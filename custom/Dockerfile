ARG base=boxy-base
FROM $base

LABEL maintainer="dev@jasoncarloscox.com"

# user environment variable defined in base image
COPY . /home/$USER/.boxy
RUN boxy-setup /home/$USER

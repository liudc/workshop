# Set the base image
FROM elixir

# Dockerfile maintainer
MAINTAINER Decheng <dechengl@amazon.com>

# install phoenix
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

# install postgres
RUN apt-get update && \
  apt-get install -y postgresql-client && \
  apt-get install -y vim && \
  apt-get install -y sed

# install node
RUN curl -sL https://deb.nodesource.com/setup_7.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install nodejs

# Create app directory
#RUN mix phx.new dropship
RUN mkdir /demo
WORKDIR /demo
COPY ./entry.sh /demo
RUN mix phoenix.new dropship
WORKDIR /demo/dropship

# rename database hostname
RUN sed -i -e 's/localhost/postgres_db/g' config/dev.exs

# Install hex package manager
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile

# install node dependencies
RUN npm install
# build only the things for production
RUN node node_modules/brunch/bin/brunch build

CMD ["/demo/entry.sh"]

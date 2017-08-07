FROM ruby:2.4
MAINTAINER leifcr@gmail.com

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libmysqlclient-dev \
  libxml2-dev \
  libxslt1-dev \
  mysql-client \
  wget \
  nodejs

# For staging and production env, duck-cli must be installed to be able to download refile assets
# If encoding errors occur, adjust locale.
ENV APP_HOME /app \
    LANG C.UTF-8 \
    PHANTOMJS_VERSION 2.1.1

RUN set -x  \
 && mkdir /tmp/phantomjs \
 && cd /tmp/phantomjs \
 && wget -nv https://github.com/Medium/phantomjs/releases/download/v$PHANTOMJS_VERSION/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -O - \
   | tar -xj --strip-components=1 -C /tmp/phantomjs \
 && mv /tmp/phantomjs/bin/phantomjs /usr/local/bin \
 && mkdir $APP_HOME \
 && groupadd -g 1000 rails \
 && useradd -s /bin/bash -m -d /home/rails -g rails rails \
 && chown rails:rails /app

# Copy docker entry point
COPY docker-entrypoint.sh /usr/local/bin/

# Make entrypoint executable when building on Windows
# And backwards compatible entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Continue as rails user
USER rails

# Set workdir to /app, so COPY, ADD, RUN and ENTRYPOINT is run within folder
WORKDIR $APP_HOME

# Add Gemfile
COPY Gemfile Gemfile.lock ./
# Install gems
RUN gem install bundler && bundle install --jobs 20 --retry 5
# Disable skylight dev warning
RUN skylight disable_dev_warning

# Set entry point to bundle exec, as all cmd's with rails should be prepended
ENTRYPOINT ["docker-entrypoint.sh"]

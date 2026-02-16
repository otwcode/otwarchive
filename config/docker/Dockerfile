FROM ruby:3.4.6

# Install additional packages
RUN apt-get update             && \
    apt-get install -y            \
        calibre                   \
        default-mysql-client      \
        libvips                   \
        shared-mime-info          \
        zip

# Clean and mount repository at /otwarchive
RUN rm -rf /otwarchive && mkdir -p /otwarchive
WORKDIR /otwarchive
VOLUME /otwarchive

# Install ruby packages
COPY Gemfile .
COPY Gemfile.lock .
RUN gem install bundler -v 2.6.9 && bundle install

# Default command to run in a new container
EXPOSE 3000
CMD bundle exec rails s -p 3000

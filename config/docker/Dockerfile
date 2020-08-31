FROM ruby:2.6.5

# Install additional packages
RUN apt-get update             && \
    apt-get install -y            \
        calibre                   \
        default-mysql-client      \
        phantomjs                 \
        pwgen                     \
        wkhtmltopdf               \
        zip

# Clean and mount repository at /otwa
RUN rm -rf /otwa && mkdir -p /otwa
WORKDIR /otwa
VOLUME /otwa

# Install ruby packages
COPY Gemfile .
COPY Gemfile.lock .
RUN gem install bundler -v 1.17.3 && bundle install

# Install linters
COPY Gemfile.linters .
COPY Gemfile.linters.lock .
BUNDLE_GEMFILE=Gemfile.linters bundle install

# Default command to run in a new container
EXPOSE 3000
CMD bundle exec rails s -p 3000

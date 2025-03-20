FROM ruby:3.3-slim-bookworm

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libsqlite3-dev \
      libxml2-dev \
      libxslt1-dev \
      && rm -rf /var/lib/apt/lists/*

COPY checker.rb /app/checker.rb

RUN gem install nokogiri sqlite3

ENTRYPOINT ["ruby", "/app/checker.rb"]


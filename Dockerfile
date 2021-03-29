#Node.js & Yarn
FROM node:13.14-stretch as node
FROM yyachi/ruby-fits:2.7.2 as ruby-fits 

FROM ubuntu:bionic as build-env
RUN apt-get update \
&& apt-get -y install git curl make openssl zlib1g-dev libssl1.0-dev libreadline-dev build-essential \
libpq-dev \
#postgresql-client \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/sstephenson/rbenv.git /opt/rbenv \
&& git clone https://github.com/sstephenson/ruby-build.git /opt/rbenv/plugins/ruby-build \
&& /opt/rbenv/plugins/ruby-build/install.sh
ENV PATH /opt/rbenv/bin:/opt/rbenv/shims:$PATH
ENV RBENV_ROOT /opt/rbenv
RUN echo 'export RBENV_ROOT="/opt/rbenv"' >> /etc/profile \
&& echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile \
&& echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
&& echo 'eval "$(rbenv init -)"' >> /etc/profile \
&& sh /etc/profile.d/rbenv.sh \
&& rbenv install 2.7.2 \
&& rbenv global 2.7.2 \
&& echo 'gem: --no-document' >> ~/.gemrc && cp ~/.gemrc /etc/gemrc && chmod uog+r /etc/gemrc
#&& gem update --system 2.7.8
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN bash -l -c 'bundle install'

# deploy
FROM misasa/image_mosaic:release-0.2.5
#FROM yyachi/image_mosaic:0.2.4
# Install Node.js and Yarn
ENV YARN_VERSION 1.22.4
RUN mkdir -p /opt
COPY --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx

RUN apt-get update && apt-get install -y \
#libpq-dev \
postgresql-client \
openssl \
#rsync \
#libssl-dev \
#libssl-dev \
#libreadline-gplv2-dev \
imagemagick \
#nfs-common \
git curl \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
#RUN git clone https://github.com/sstephenson/rbenv.git /opt/rbenv
#RUN git clone https://github.com/sstephenson/ruby-build.git /opt/rbenv/plugins/ruby-build
#RUN /opt/rbenv/plugins/ruby-build/install.sh
#ENV PATH /opt/rbenv/bin:/opt/rbenv/shims:$PATH
#ENV RBENV_ROOT /opt/rbenv
#RUN echo 'export RBENV_ROOT="/opt/rbenv"' >> /etc/profile
#RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile
#RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
#RUN echo 'eval "$(rbenv init -)"' >> /etc/profile
#RUN sh /etc/profile.d/rbenv.sh

#RUN rbenv install 2.1.7
#RUN rbenv global 2.1.7
#RUN echo 'gem: --no-document' >> ~/.gemrc && cp ~/.gemrc /etc/gemrc && chmod uog+r /etc/gemrc
#RUN gem update --system 2.7.8

# enable ghostscript format types 
#RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml
COPY ImageMagick-6-policy.xml /etc/ImageMagick-6/policy.xml
# install ruby
COPY --from=build-env /opt/rbenv /opt/rbenv
COPY --from=build-env /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0
COPY --from=build-env /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0

ENV PATH /opt/rbenv/bin:/opt/rbenv/shims:$PATH
ENV RBENV_ROOT /opt/rbenv
RUN echo 'export RBENV_ROOT="/opt/rbenv"' >> /etc/profile \
&& echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile \
&& echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
&& echo 'eval "$(rbenv init -)"' >> /etc/profile \
&& sh /etc/profile.d/rbenv.sh \
&& rbenv global 2.7.2

# install RubyFits
COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/RubyFits.rb /opt/rbenv/versions/2.7.2/lib/ruby/site_ruby/RubyFits.rb
COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/fits.so /opt/rbenv/versions/2.7.2/lib/ruby/site_ruby/fits.so

ARG UID=1000
ARG GID=1000

RUN addgroup -gid ${GID} medusa && useradd -m --home-dir /medusa --shell /bin/sh --gid ${GID} --uid ${UID} medusa \
 && mkdir -p /medusa/public/system /medusa/public/assets \
 && chown -R medusa:medusa /medusa/public

WORKDIR /medusa
COPY Gemfile Gemfile.lock /medusa/
COPY package.json yarn.lock /medusa/
RUN bash -l -c 'yarn install'
COPY . /medusa
RUN bash -l -c 'bundle install'
RUN chown -R medusa:medusa /medusa
USER medusa
ENV PATH /usr/local/bin:$PATH
RUN bundle exec rake assets:precompile
ENV PORT 3000
EXPOSE $PORT
CMD ["sh", "-c", "bundle exec rails server -p ${PORT}"]

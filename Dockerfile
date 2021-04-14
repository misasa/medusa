ARG RAILS_ENV="production"
ARG YARN_VERSION="1.22.5"
ARG RUBY_VERSION="2.7.2"
ARG BUNDLER_VERSION="2.2.8"
FROM node:lts-buster-slim as node
From ruby:${RUBY_VERSION} as ruby-fits
RUN apt-get update && apt-get install -y \
build-essential \
libpcre3-dev \
cmake \
#swig \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

#RUN git clone https://github.com/swig/swig.git
RUN wget http://prdownloads.sourceforge.net/swig/swig-4.0.2.tar.gz
RUN tar xvzf swig-4.0.2.tar.gz
RUN cd swig-4.0.2 && ./configure && make && make install

RUN wget https://www.ir.isas.jaxa.jp/~cyamauch/sli/sllib-1.4.5a.tar.gz
RUN gzip -dc sllib-1.4.5a.tar.gz | tar xvf -
RUN cd sllib-1.4.5a && make && make install32
RUN wget https://www.ir.isas.jaxa.jp/~cyamauch/sli/sfitsio-1.4.5.tar.gz
RUN gzip -dc sfitsio-1.4.5.tar.gz | tar xvf -
RUN cd sfitsio-1.4.5 \
&& make && make install32
RUN git clone https://github.com/yuasatakayuki/RubyFits.git
RUN mkdir -p RubyFits/swig/build && cd RubyFits/swig/build && cmake .. && make install
RUN cp /root/lib/ruby/* /usr/local/lib/ruby/site_ruby/

From ruby:${RUBY_VERSION} as build-python
RUN apt-get update \
&& apt-get install -y python3-pip \
&& apt-get install -y libopencv-dev 
RUN git clone https://github.com/misasa/image_mosaic.git
RUN pip3 install -r /image_mosaic/requirements.txt \
&& pip3 install /image_mosaic

From ruby:${RUBY_VERSION} as build
ARG RAILS_ENV
ARG BUNDLER_VERSION
ARG YARN_VERSION
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends\
  ghostscript \
  postgresql-client &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* &&\
  truncate -s 0 /var/log/*log

COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/RubyFits.rb /usr/local/lib/ruby/site_ruby/RubyFits.rb
COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/fits.so /usr/local//lib/ruby/site_ruby/fits.so

COPY --from=build-python /usr/lib/x86_64-linux-gnu/libSM.so.6 /usr/lib/x86_64-linux-gnu/libSM.so.6
COPY --from=build-python /usr/lib/x86_64-linux-gnu/libICE.so.6 /usr/lib/x86_64-linux-gnu/libICE.so.6

COPY --from=build-python /usr/local/lib/python3.7 /usr/local/lib/python3.7 
COPY --from=build-python /usr/local/bin/make_tiles /usr/local/bin/make_tiles
COPY --from=build-python /usr/local/bin/image_in_image /usr/local/bin/image_in_image
COPY --from=build-python /usr/local/bin/Haffine_from_points /usr/local/bin/Haffine_from_points
COPY --from=build-python /usr/local/bin/H_from_points /usr/local/bin/H_from_points
COPY ImageMagick-6-policy.xml /etc/ImageMagick-6/policy.xml

RUN mkdir -p /opt
COPY --from=node /opt/yarn-v${YARN_VERSION} /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx
RUN useradd -m --home-dir /medusa medusa
USER medusa
WORKDIR /medusa
COPY --chown=medusa:medusa Gemfile Gemfile.lock /medusa/
RUN gem install bundler --version ${BUNDLER_VERSION} && \
    bundle config set --local path 'vendor/bundler'
RUN if [ "${RAILS_ENV}" = "production" ]; then \
  bundle config set --local without 'development test'; \
fi
RUN bundle install
COPY --chown=medusa:medusa package.json yarn.lock /medusa/
RUN yarn install && yarn cache clean
RUN mkdir /medusa/app
RUN mkdir /medusa/log
RUN mkdir -p /medusa/public/assets
RUN mkdir -p /medusa/public/packs
COPY --chown=medusa:medusa Rakefile /medusa/
COPY --chown=medusa:medusa config /medusa/config
COPY --chown=medusa:medusa app/models/application_record.rb /medusa/app/models/application_record.rb
COPY --chown=medusa:medusa app/models/unit.rb /medusa/app/models/unit.rb
COPY --chown=medusa:medusa app/models/user.rb /medusa/app/models/user.rb
COPY --chown=medusa:medusa lib /medusa/lib
COPY --chown=medusa:medusa app/webpack /medusa/app/webpack
COPY --chown=medusa:medusa app/assets /medusa/app/assets
COPY --chown=medusa:medusa bin /medusa/bin
COPY --chown=medusa:medusa postcss.config.js /medusa/postcss.config.js
RUN if [ "${RAILS_ENV}" = "production" ]; then \
  bundle exec rake assets:precompile &&\
  rm -rf node_modules/*; \
fi
COPY --chown=medusa:medusa app /medusa/app
COPY --chown=medusa:medusa config.ru /medusa/config.ru
COPY --chown=medusa:medusa db /medusa/db
COPY --chown=medusa:medusa README.md /medusa/README.md
COPY --chown=medusa:medusa LICENSE /medusa/LICENSE
COPY --chown=medusa:medusa spec /medusa/spec
ENV PATH $PATH:/medusa/bin

From ruby:${RUBY_VERSION}-slim as prod
ARG RAILS_ENV
ARG YARN_VERSION
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends\
  python3 \
  file \
  ghostscript \
  imagemagick \
  libpq-dev \
  postgresql-client \
  shared-mime-info &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* &&\
  truncate -s 0 /var/log/*log

COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/RubyFits.rb /usr/local/lib/ruby/site_ruby/RubyFits.rb
COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/fits.so /usr/local//lib/ruby/site_ruby/fits.so

COPY --from=build-python /usr/lib/x86_64-linux-gnu/libSM.so.6 /usr/lib/x86_64-linux-gnu/libSM.so.6
COPY --from=build-python /usr/lib/x86_64-linux-gnu/libICE.so.6 /usr/lib/x86_64-linux-gnu/libICE.so.6
COPY --from=build-python /usr/lib/x86_64-linux-gnu/libXrender.so.1 /usr/lib/x86_64-linux-gnu/libXrender.so.1

COPY --from=build-python /usr/local/lib/python3.7 /usr/local/lib/python3.7 
COPY --from=build-python /usr/local/bin/make_tiles /usr/local/bin/make_tiles
COPY --from=build-python /usr/local/bin/image_in_image /usr/local/bin/image_in_image
COPY --from=build-python /usr/local/bin/Haffine_from_points /usr/local/bin/Haffine_from_points
COPY --from=build-python /usr/local/bin/H_from_points /usr/local/bin/H_from_points

COPY ImageMagick-6-policy.xml /etc/ImageMagick-6/policy.xml

# Install Node.js and Yarn
RUN mkdir -p /opt
COPY --from=node /opt/yarn-v${YARN_VERSION} /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx
RUN useradd -m --home-dir /medusa medusa
USER medusa
WORKDIR /medusa
COPY --chown=medusa:medusa --from=build /medusa /medusa
COPY --chown=medusa:medusa --from=build /usr/local/bundle/config /usr/local/bundle/config
ENV PATH $PATH:/medusa/bin
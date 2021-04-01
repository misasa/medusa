FROM node:lts-stretch as node
FROM yyachi/ruby-fits:2.7.2 as ruby-fits 
From ruby:2.7.2 as build-env

# build image_mosaic
RUN apt-get update \
&& apt-get install -y python3-pip \
&& apt-get install -y libopencv-dev 
RUN git clone https://github.com/misasa/image_mosaic.git
RUN pip3 install -r /image_mosaic/requirements.txt \
&& pip3 install /image_mosaic

# Install Node.js and Yarn
ENV YARN_VERSION 1.22.5
RUN mkdir -p /opt
COPY --from=node /opt/yarn-v$YARN_VERSION /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx


ARG UID=1000
ARG GID=1000

RUN addgroup -gid ${GID} medusa && useradd -m --home-dir /medusa --shell /bin/sh --gid ${GID} --uid ${UID} medusa \
 && mkdir -p /medusa/public/system /medusa/public/assets \
 && chown -R medusa:medusa /medusa/public

WORKDIR /medusa
COPY Gemfile Gemfile.lock /medusa/
COPY package.json yarn.lock /medusa/
#RUN bash -l -c 'yarn install'
COPY . /medusa
RUN bash -l -c 'bundle install'
ENV PATH /usr/local/bin:$PATH
RUN yarn install
RUN bundle exec rake assets:precompile
RUN chown -R medusa:medusa /medusa
USER medusa
# install RubyFits
COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/RubyFits.rb /usr/local/lib/ruby/site_ruby/RubyFits.rb
COPY --from=ruby-fits /usr/local/lib/ruby/site_ruby/fits.so /usr/local//lib/ruby/site_ruby/fits.so
COPY ImageMagick-6-policy.xml /etc/ImageMagick-6/policy.xml

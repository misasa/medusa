FROM valian/docker-python-opencv-ffmpeg
RUN pip install --upgrade pip
RUN pip install git+https://github.com/misasa/image_mosaic.git

RUN apt-get update && apt-get install -y \
apt-transport-https \
curl \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y \
libpq-dev postgresql-client rsync libssl-dev \
libreadline-gplv2-dev imagemagick nfs-common \
nodejs yarn \
zlib1g-dev \
libbz2-dev \
swig \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
RUN wget https://www.ir.isas.jaxa.jp/~cyamauch/sli/sllib-1.4.5a.tar.gz
RUN gzip -dc sllib-1.4.5a.tar.gz | tar xvf -
RUN cd sllib-1.4.5a && make && make install32
RUN wget https://www.ir.isas.jaxa.jp/~cyamauch/sli/sfitsio-1.4.5.tar.gz
RUN gzip -dc sfitsio-1.4.5.tar.gz | tar xvf -
RUN cd sfitsio-1.4.5 \
&& sed -i 's/\!isfinite(\*/\!isfinite((float) \*/' fits_table_col.cc \
&& sed -i 's/\!isfinite(\*/\!isfinite((float) \*/' fits_image.cc \
&& make && make install32
RUN git clone https://github.com/sstephenson/rbenv.git /opt/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /opt/rbenv/plugins/ruby-build
RUN /opt/rbenv/plugins/ruby-build/install.sh
ENV PATH /opt/rbenv/bin:/opt/rbenv/shims:$PATH
ENV RBENV_ROOT /opt/rbenv
RUN echo 'export RBENV_ROOT="/opt/rbenv"' >> /etc/profile
RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile
RUN sh /etc/profile.d/rbenv.sh

#RUN /root/.rbenv/plugins/ruby-build/install.sh
#ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
#RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
#RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
#RUN sh /etc/profile.d/rbenv.sh
#ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install 2.1.7
RUN rbenv global 2.1.7
RUN echo 'gem: --no-document' >> ~/.gemrc && cp ~/.gemrc /etc/gemrc && chmod uog+r /etc/gemrc
RUN gem update --system 2.7.8

RUN git clone https://github.com/yuasatakayuki/RubyFits.git
RUN mkdir -p RubyFits/swig/build && cd RubyFits/swig/build && cmake .. && make install
RUN cp /root/lib/ruby/* /opt/rbenv/versions/2.1.7/lib/ruby/site_ruby/

ARG UID=1000
ARG GID=1000

RUN addgroup -gid ${GID} medusa && useradd -m --home-dir /medusa --shell /bin/sh --gid ${GID} --uid ${UID} medusa \
 && mkdir -p /medusa/public/system /medusa/public/assets \
 && chown -R medusa:medusa /medusa/public

#RUN mkdir -p /usr/src/app
WORKDIR /medusa
COPY Gemfile Gemfile.lock /medusa/
RUN bash -l -c 'bundle install'
COPY package.json yarn.lock /medusa/
RUN bash -l -c 'yarn install'
COPY . /medusa
RUN chown -R medusa:medusa /medusa
USER medusa
ENV PORT 3000
EXPOSE $PORT
CMD ["sh", "-c", "bundle exec rails server -p ${PORT}"]
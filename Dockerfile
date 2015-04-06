FROM ruby:2.1.2

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD . /usr/src/app
RUN bundle install --system

EXPOSE 4568

CMD ["bash", "-c", "docker/start_it_up.sh"]


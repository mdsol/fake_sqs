FROM ruby:2.1.2

RUN apt-get update
RUN apt-get -y install procps vim

RUN mkdir -p /var/data/fake_sqs

RUN mkdir -p /app
WORKDIR /app

ADD . /app
RUN bundle install --system

EXPOSE 4568

CMD ["bash", "-c", "docker/start_it_up.sh"]


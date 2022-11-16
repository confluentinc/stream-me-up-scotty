FROM debezium/example-postgres

ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres

RUN mkdir /data
COPY data/* /data/

RUN rm /docker-entrypoint-initdb.d/inventory.sql
COPY setup.sql /docker-entrypoint-initdb.d/
ADD setup.sql /docker-entrypoint-initdb.d
RUN chmod a+r /docker-entrypoint-initdb.d/*

EXPOSE 5432
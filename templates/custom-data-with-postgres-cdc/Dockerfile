FROM debezium/example-postgres:2.0

ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=SuPeRsEcUr3!

# Make the data directory and copy your data in there
RUN mkdir /data
COPY data/* /data/

# Remove the "script" that comes with the Debezium example
RUN rm /docker-entrypoint-initdb.d/inventory.sql

# Add your own "scripts" to the entrypoint, they will be run 
# on startup
COPY scripts/* /docker-entrypoint-initdb.d/
ADD scripts/* /docker-entrypoint-initdb.d
RUN chmod a+r /docker-entrypoint-initdb.d/*

# Expose the default Postgres port
EXPOSE 5432
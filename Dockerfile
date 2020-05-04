FROM python:3.7-alpine

EXPOSE 5000

# Controls whether to install extra dependencies needed for all data sources.
ARG skip_ds_deps

RUN adduser -S redash

# Ubuntu packages
RUN apk update
RUN apk add curl \
    gnupg \
    pwgen \
    libffi-dev \
    sudo \
    wget

RUN apk add postgresql-client  gcc libc-dev g++ libffi-dev libxml2 unixodbc-dev mariadb-dev postgresql-dev

# for SAML
RUN apk add \
    build-base \
    libressl \
    libressl-dev \
    libffi-dev \
    libxslt-dev \
    libxml2-dev

# Additional packages required for data sources:
RUN apk add freetds-dev unzip

# MSSQL ODBC Driver:
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.2.2-1_amd64.apk
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.2.1-1_amd64.apk

#Install the package(s)
RUN sudo apk add -f --allow-untrusted msodbcsql17_17.5.2.2-1_amd64.apk
RUN sudo apk add -f --allow-untrusted mssql-tools_17.5.2.1-1_amd64.apk

WORKDIR /app

# Disalbe PIP Cache and Version Check
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# We first copy only the requirements file, to avoid rebuilding on every file
# change.
COPY requirements.txt requirements_bundles.txt requirements_dev.txt requirements_all_ds.txt ./
RUN pip install -r requirements.txt -r requirements_dev.txt
RUN if [ "x$skip_ds_deps" = "x" ] ; then pip install -r requirements_all_ds.txt ; else echo "Skipping pip install -r requirements_all_ds.txt" ; fi

#COPY . /app
#COPY ./client/dist /app/client/dist
USER redash

ENTRYPOINT ["/app/bin/docker-entrypoint"]

CMD ["server"]

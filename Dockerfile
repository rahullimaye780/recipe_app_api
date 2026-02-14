FROM python:3.9-alpine3.13
LABEL maintainer="Rahul Limaye"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# below Run command runs multiple commands in one layer,to run multiple commands '&& \' is used to chain them together.
#It creates a virtual environment, upgrades pip, installs the required packages, removes the temporary files and adds a new user 'django-user' with no password and no home directory.



RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \

ENV PATH="/py/bin:$PATH"

USER django-user
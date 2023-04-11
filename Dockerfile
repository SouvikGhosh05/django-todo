FROM python:3.10-slim-bullseye
RUN apt-get update && apt-get install nginx curl -y
COPY . /django-app
WORKDIR /django-app
RUN python -m venv /opt/venv && \
    /opt/venv/bin/python -m pip install pip --upgrade && \
    /opt/venv/bin/python -m pip install -r requirements.txt
RUN cp nginx/default.conf /etc/nginx/conf.d/default.conf && chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]

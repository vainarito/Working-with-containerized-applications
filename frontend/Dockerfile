FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY index.html .
COPY style.css .
COPY app.js .

RUN apk add --no-cache gettext curl
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx-entrypoint.sh /docker-entrypoint.d/99-envsubst.sh
RUN chmod +x /docker-entrypoint.d/99-envsubst.sh

EXPOSE 80

WORKDIR /usr/share/nginx/html

COPY index.html .
COPY style.css .
COPY app.js .

RUN apk add --no-cache gettext
COPY nginx-entrypoint.sh /docker-entrypoint.d/99-envsubst.sh
RUN chmod +x /docker-entrypoint.d/99-envsubst.sh

EXPOSE 80

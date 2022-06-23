FROM debian:11.3 AS build

ENV NGINX_VERSION=1.23.0
ENV NGINX_RTMP_MODULE_VERSION=1.2.2

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    build-essential \
    ca-certificates \
    curl \
    libpcre3-dev \
    libssl-dev \
    libz-dev

WORKDIR /build
RUN curl -O "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
  && tar xvzf nginx-${NGINX_VERSION}.tar.gz
RUN curl -LO "https://github.com/arut/nginx-rtmp-module/archive/refs/tags/v${NGINX_RTMP_MODULE_VERSION}.tar.gz" \
  && tar xvzf v${NGINX_RTMP_MODULE_VERSION}.tar.gz

WORKDIR /build/nginx-${NGINX_VERSION}
RUN ./configure \
    --add-dynamic-module="/build/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}" \
    --with-compat \
  && make modules \
  && cp objs/ngx_rtmp_module.so /build/ngx_rtmp_module.so

FROM nginx:1.23.0

LABEL maintainer 'koyashiro <develop@koyashi.ro>'

COPY --from=build /build/ngx_rtmp_module.so /usr/lib/nginx/modules/ngx_rtmp_module.so

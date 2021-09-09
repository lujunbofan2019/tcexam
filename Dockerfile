FROM fuyuanli/xampp
EXPOSE 80

VOLUME /tmp

# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

FROM cosmicexplorer/mailman-core-apache-shib:1

RUN apt-get -y install cron
    
COPY restart-apache /etc/cron.daily/restart-apache
RUN chmod +x /etc/cron.daily/restart-apache

RUN /bin/echo -e "\n\
[program:cron]\n\
command=/usr/sbin/cron -f\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n" >> /usr/local/etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]

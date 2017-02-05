FROM ubuntu

#RUN echo "deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" > /etc/apt/sources.list.d/100-ubnt.list && \
RUN echo "deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti" > /etc/apt/sources.list.d/100-ubnt.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 && \
    apt-get --assume-yes update && \
    apt-get --assume-yes install unifi && \
    apt-get --assume-yes clean

EXPOSE 8080
EXPOSE 8443
EXPOSE 6789

RUN mkdir /var/lib/unifi
COPY system.properties /var/lib/unifi/

RUN sed -i 's/JSVC_EXTRA_OPTS=/JSVC_EXTRA_OPTS=\"-nodetach\"/' /etc/init.d/unifi 

VOLUME /var/lib/unifi

ENTRYPOINT ["/etc/init.d/unifi", "start"]

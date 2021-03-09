FROM alpine:3.13

ENV DHCP_RANGE_BEGIN 192.168.111.50
ENV DHCP_RANGE_END 192.168.111.100

RUN apk --no-cache add dnsmasq syslinux
RUN mkdir /tftpboot
RUN cp -r /usr/share/syslinux /tftpboot/
RUN ln -sf syslinux/pxelinux.0 /tftpboot/pxelinux.0
RUN chown -R nobody:nogroup /tftpboot
RUN mkdir /tftpboot/pxelinux.cfg
COPY syslinux.cfg /tftpboot/pxelinux.cfg/default
COPY dnsmasq.conf /etc/dnsmasq.conf
VOLUME /tftpboot/images
VOLUME /etc/dnsmasq.d/
COPY entry.sh /usr/bin/entry.sh
RUN chmod +x /usr/bin/entry.sh
CMD /usr/bin/entry.sh

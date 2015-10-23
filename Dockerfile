FROM ubuntu:trusty
MAINTAINER Dave P

# Create user (user/password is deluge)
RUN useradd --create-home --uid 1000 deluge ; \
    echo "deluge:deluge" | chpasswd ; \
    locale-gen en

# Install deluge
COPY auth /home/deluge/.config/deluge/
COPY core.conf /home/deluge/.config/deluge/
COPY web_plugin.conf /home/deluge/.config/deluge/
COPY web.conf /home/deluge/.config/
COPY run_deluge.sh /
RUN apt-get update ; \
    apt-get install -y software-properties-common ; \
    add-apt-repository -y ppa:deluge-team/ppa ; \
    apt-get update ; \
    apt-get -y install deluged deluge-web deluge-console ; \ 
    chown -R deluge /home/deluge/.config ; \
    chgrp -R deluge /home/deluge/.config ; \
    chmod +x /run_deluge.sh

# Install supervisor, vnstat, & start script
RUN apt-get -y install supervisor vnstat ; mkdir /start.d
COPY deluged.conf /etc/supervisor/conf.d/deluged.conf 
COPY vnstatd.conf etc/supervisor/conf.d/vnstatd.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start /start
RUN chmod +x /start ; \
    chown -R deluge /var/lib/vnstat ; \
    chgrp -R deluge /var/lib/vnstat ; \
    sed -i -e"s/^UnitMode\s0/UnitMode 1/" /etc/vnstat.conf ; \
    sed -i -e"s/^RateUnit\s1/RateUnit 0/" /etc/vnstat.conf

# Install openvpn
RUN apt-get install -y openvpn ; dpkg -l
COPY openvpn.conf /etc/supervisor/conf.d/openvpn.conf

# Expose deluge-web, deluge
EXPOSE 8112
EXPOSE 58846
#EXPOSE 8113 # deluge-web https

# REMEMBER TO MANUALLY SPECIFY A PEER PORT ON RUN

# Set boot command
CMD /start


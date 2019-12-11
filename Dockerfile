FROM debian:buster-slim
MAINTAINER DJustDE <docker@djust.de>

ENV GAME ttt
ENV STEAMCMDDIR /home/steam/steam

ENV PORT=27015
ENV PORTTV=27020
ENV CLIENTPORT=27005
ENV SPORT=26900
ENV MAXPLAYERS=12
ENV GAMEMODE=terrortown
ENV MAP=gm_construct
ENV SERVERNAME=
ENV PASSWD=
ENV RCONPASSWD=
ENV WORKSHOPCOLLECTION=
ENV APIKEY=
ENV SERVERACCOUNT=

# --> 27015/tcp=Rcon; 27015/udp=information; 27005/udp=client; 27020/udp=SourceTV; 26900/udp=steam
EXPOSE 27015/tcp 27015/udp 27005/udp 27020/udp 26900/udp

# --> only ARK server
# EXPOSE 7777-7778/tcp 7777-7778/udp
# RUN echo "fs.file-max=100000" >> /etc/sysctl.conf && /
#    echo "* soft nofile 1000000" >> /etc/security/limits.conf && /
#    echo "* hard nofile 1000000" >> /etc/security/limits.conf && /
#    echo "session required pam_limits.so" >> /etc/pam.d/common-session

# ---- >> Server Update
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests lib32stdc++6 lib32gcc1 wget ca-certificates curl screen sudo bash
# ---- >> add user, group steam and add home dir
RUN addgroup --gid 1000 steam && \
    adduser --uid 1000 --ingroup steam --no-create-home --disabled-password --disabled-login steam && \
    mkdir -p ${STEAMCMDDIR} && cd ${STEAMCMDDIR} && \
    chmod -R 0775 ${STEAMCMDDIR} && \
    chown steam.steam ${STEAMCMDDIR}
# RUN echo 'steam ALL=(ALL) NOPASSWD: ALL' >> '/etc/sudoers'

# ---- >> copy start script
COPY /data ${STEAMCMDDIR}
WORKDIR ${STEAMCMDDIR}

# ---- >> Install steam cmd
RUN su steam -c "wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf -" && \
    su steam -c "${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit"
#    ln -s ${STEAMCMDDIR}/linux32/steamclient.so ${STEAMCMDDIR}/.steam/sdk32/steamclient.so
# RUN chown steam.steam ${STEAMCMDDIR} && \
# RUN chmod -R 0775 ${STEAMCMDDIR}

RUN ls ${STEAMCMDDIR}

USER steam
VOLUME ${STEAMCMDDIR}
ENTRYPOINT ["${STEAMCMDDIR}/entrypoint"]

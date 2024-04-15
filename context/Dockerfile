FROM registry.access.redhat.com/ubi9-minimal:latest

RUN microdnf install -y glibc.i686 libstdc++.i686 tar gzip \
	--setopt=install_weak_deps=0 \
	--setopt=tsflags=nodocs \
	&& microdnf clean all -y

RUN mkdir -p /root/.steam \
	&& chmod -R 775 /root/.steam \
	&& cd /root/.steam \
	&& curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxf - \
	&& export PATH=$PATH:/root/.steam \
	&& steamcmd.sh +quit 

# Fix missing links to support applications that rely on them, such as proton
RUN ln -s /root/.steam/linux32 /root/.steam/sdk32 \
	&& ln -s /root/.steam/linux64 /root/.steam/sdk64 \
	&& ln -s /root/.steam/sdk32/steamclient.so /root/.steam/sdk32/steamservice.so \
	&& ln -s /root/.steam/sdk64/steamclient.so /root/.steam/sdk64/steamservice.so

ENV PATH $PATH:/root/.steam
LABEL NAME=steamcmd
ENTRYPOINT ["steamcmd.sh"]
CMD ["+help", "+quit"]

FROM ubuntu

WORKDIR /app
###### This stuff makes development faster by caching this layers ######
COPY install.sh .
RUN bash ./install.sh
RUN bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils"
RUN bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils nodejs npm"
########################################################################
COPY . .
RUN zsh --interactive -c "echo Building container complete"

CMD ["zsh","-l"]

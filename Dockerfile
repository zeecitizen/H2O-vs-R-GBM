FROM ubuntu:14.04
MAINTAINER Mohammad Zeeshan <zeeshan@mit.edu>
RUN apt-get -qqy update

# add webupd8 repository
RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get -qqy update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
    \
    \
    echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean all  && \
    rm -rf /var/lib/apt/lists/*


# define default command
 CMD ["java"]

 ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-get -qqy update
RUN apt-get install -y libcurl4-gnutls-dev
RUN apt-get install -y -q r-base r-base-dev gdebi-core libapparmor1 supervisor wget
RUN (wget https://download2.rstudio.org/rstudio-server-1.0.44-amd64.deb && gdebi -n rstudio-server-1.0.44-amd64.deb)
RUN apt-get install  -y -q r-cran-ggplot2
RUN rm /rstudio-server-1.0.44-amd64.deb
RUN (adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd)
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8787
CMD ["/usr/bin/supervisord"]

ADD 2005.csv /home/guest/2005.csv
ADD 2006.csv /home/guest/2006.csv
ADD 2007.csv /home/guest/2007.csv
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('data.table')"


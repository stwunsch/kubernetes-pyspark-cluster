FROM ubuntu:focal

RUN apt update && \
    ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    apt install default-jdk scala git python3 wget -y && \
    apt clean
RUN wget https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop2.7.tgz && \
    tar xvf spark-* && \
    mv spark-3.0.1-bin-hadoop2.7 /opt/spark && \
    rm spark-*

ENV SPARK_HOME /opt/spark
ENV PATH $PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# syntax=docker/dockerfile:1
FROM ubuntu:latest
WORKDIR /app
#COPY extract_clinvar .
#COPY mutagenesis .
SHELL ["/bin/bash", "-c"]
RUN apt update && apt upgrade -y && apt install build-essential software-properties-common xvfb bcftools default-jre bedtools bbmap vim git gawk default-jre python3 python3-pip autoconf wget unzip libglib2.0-dev libncurses-dev libcurl4-openssl-dev curl zlib1g-dev libbz2-dev liblzma-dev -y
RUN git clone --recurse-submodules --remote-submodules https://github.com/samtools/htslib.git && make -j `cat /proc/cpuinfo | grep cores | wc -l` -C htslib && make install -C htslib
RUN git clone https://github.com/samtools/samtools.git && make -j `cat /proc/cpuinfo | grep cores | wc -l` -C samtools && make install -C samtools
RUN git clone https://github.com/lh3/bwa.git && make -j `cat /proc/cpuinfo | grep cores | wc -l` -C bwa && cp bwa/bwa /usr/bin/bwa
RUN wget https://github.com/broadinstitute/picard/releases/download/1.131/picard-tools-1.131.zip && unzip picard-tools-1.131.zip
RUN git clone https://github.com/adamewing/exonerate.git && cd exonerate && git checkout v2.4.0 && autoreconf -i && ./configure && make -j `cat /proc/cpuinfo | grep cores | wc -l` && make check && make install && cd /app
RUN git clone https://github.com/dzerbino/velvet.git && cd velvet && make -j `cat /proc/cpuinfo | grep cores | wc -l` && cp velvetg /usr/bin/ && cp velveth /usr/bin && cd /app
RUN pip install pysam
RUN wget https://data.broadinstitute.org/igv/projects/downloads/2.16/IGV_2.16.2.zip
RUN unzip IGV_2.16.2.zip
RUN mv IGV_2.16.2 igv
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b
RUN source ~/miniconda3/bin/activate
RUN ~/miniconda3/bin/conda init
RUN ~/miniconda3/bin/conda install -c biobuilds -y tmap
RUN ln -s ~/miniconda3/bin/tmap-ion ~/miniconda3/bin/tmap
ARG DISABLE_CACHE
RUN git clone https://github.com/jereiard/bamsurgeon.git && cd bamsurgeon && python3 -O scripts/check_dependencies.py
COPY prep .
RUN chmod +x prep
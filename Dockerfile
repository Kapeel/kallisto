# Kallisto
# VERSION               0.42.3
#### # Kallisto - kallisto is a program for quantifying abundances of transcripts from RNA-Seq data # Nicolas L Bray, Harold Pimentel, Páll Melsted and Lior Pachter, Near-optimal probabilistic RNA-seq quantification # Nature Biotechnology 34, 525–527 (2016), doi:10.1038/nbt.3519 ####
#

FROM      ubuntu:14.04.3
MAINTAINER Kapeel Chougule

LABEL Description="This image is used for running Kallisto RNA seq qauntification tool "
RUN apt-get update && apt-get install -y build-essential cmake zlib1g-dev libhdf5-dev

#install git
RUN apt-get install --yes git

RUN git clone https://github.com/pachterlab/kallisto.git \
&& cd kallisto \
&& git checkout 5c5ee8a45d6afce65adf4ab18048b40d527fcf5c \
&& mkdir build \
&& cd build \
&& cmake .. \
&& make \
&& make install

ADD Kallisto_align.pl /usr/bin/
RUN [ "chmod", "+x",  "/usr/bin/Kallisto_align.pl" ]
ENTRYPOINT ["Kallisto_align.pl"]

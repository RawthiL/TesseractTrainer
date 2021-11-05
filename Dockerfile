ARG UBUNTU_VERSION


FROM ubuntu:${UBUNTU_VERSION}

ENV TZ=America/Argentina
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends --allow-unauthenticated  \
                                g++ \
                                autoconf automake libtool \
                                pkg-config \
                                libpng-dev \
                                libjpeg8-dev \
                                libtiff5-dev \
                                zlib1g-dev \
                                libicu-dev \
                                libpango1.0-dev \
                                libcairo2-dev 

RUN apt-get install -y wget

RUN apt-get install -y libleptonica-dev

RUN apt-get install -y software-properties-common
RUN add-apt-repository "ppa:alex-p/tesseract-ocr-devel"
RUN apt-get update 

RUN apt-get install -y libtesseract-dev 
RUN apt-get install -y tesseract-ocr


# Get latest BEST tessetact models for english and spanish
RUN wget -N https://github.com/tesseract-ocr/tessdata_best/blob/main/eng.traineddata?raw=true -O /usr/share/tesseract-ocr/5/tessdata/eng.traineddata
RUN wget -N https://github.com/tesseract-ocr/tessdata_best/blob/main/spa.traineddata?raw=true -O /usr/share/tesseract-ocr/5/tessdata/esp.traineddata

# Create user
RUN useradd -ms /bin/bash tesstrain
RUN chown -R tesstrain:tesstrain /home/tesstrain

# Set the work directory
WORKDIR /home/tesstrain

# Create model path
RUN mkdir lstm_model
# Create input and output mount points
RUN mkdir train_samples
RUN mkdir validation_samples
RUN mkdir output

# Add scripts
COPY convert2lstm.py .
COPY do_train.sh .
RUN chmod +x do_train.sh

RUN chown tesstrain:tesstrain -R /home/tesstrain
RUN apt-get install -y nano
# Set user
USER tesstrain

# Set entrypoint train script
ENTRYPOINT ["/bin/bash", "/home/tesstrain/do_train.sh"]
# Set default parameters:
# 0: Process all .tiff and .box into .lstm
# 11: Use psm=11 to detect text 
# 10000: Train for 10000 iterations
CMD ["0", "11", "10000"]

# Usage:
# docker run -u $UID:$UID -v <host path to train samples>:/home/tesstrain/train_samples \
#                         -v <host path to validation samples>:/home/tesstrain/validation_samples \
#                         -v <host path to output directory>:/home/tesstrain/output \
#                         -it tesseract_trainer:5.0 <optionally override argumets for train script>

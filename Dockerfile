FROM nvcr.io/nvidia/pytorch:22.08-py3
LABEL maintainer="Mingjie Liu <mingjiel@nvidia.com>"
RUN echo "alias python=python3" >> ~/.bashrc \
        && echo "alias pip=pip3" >> ~/.bashrc
RUN apt-get -y update \
        && apt-get -y install vim 
RUN apt-get install wget
RUN apt-get install -y autoconf gperf flex bison screen
RUN python -m pip install --upgrade pip
RUN python -m pip install deepspeed scikit-learn pandas numpy scipy wandb
RUN python -m pip install accelerate>=0.12.0 torch>=1.3 datasets>=1.8.0 sentencepiece!=0.1.92 protobuf evaluate
RUN python -m pip install git+https://github.com/huggingface/transformers/
RUN git clone https://github.com/steveicarus/iverilog.git && cd iverilog \
        && git checkout 01441687235135d1c12eeef920f75d97995da333 \
        && sh ./autoconf.sh && ./configure && make -j4\
        && make install
RUN python -m pip install jupyterlab
RUN python -m pip install openai tiktoken
ENV SHELL=/bin/bash
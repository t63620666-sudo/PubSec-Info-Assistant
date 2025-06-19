# FROM mcr.microsoft.com/azure-functions/python:4-python3.12-appservice
FROM mcr.microsoft.com/azure-functions/python:4-python3.12

ARG TIKTOKEN_URL_cl100k="https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"
ARG TIKTOKEN_URL_o200k="https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken"

RUN mkdir /opt/tiktoken_cache && \
    wget -O /opt/tiktoken_cache/$(echo -n $TIKTOKEN_URL_cl100k | sha1sum | head -c 40) $TIKTOKEN_URL_cl100k && \
    wget -O /opt/tiktoken_cache/$(echo -n $TIKTOKEN_URL_o200k | sha1sum | head -c 40) $TIKTOKEN_URL_o200k
    
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    TIKTOKEN_CACHE_DIR=/opt/tiktoken_cache

WORKDIR /home/site/wwwroot

COPY ./requirements.txt requirements.txt

RUN pip install -r ./requirements.txt && \
    python -m nltk.downloader -d /usr/local/share/nltk_data punkt_tab averaged_perceptron_tagger_eng

    # Copy the package.json
COPY . .

# Use the official Node.js image
FROM mcr.microsoft.com/devcontainers/python:3.12

ARG TIKTOKEN_URL_cl100k="https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"
ARG TIKTOKEN_URL_o200k="https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken"

# Install the dependencies
RUN mkdir /opt/tiktoken_cache && \
    wget -O /opt/tiktoken_cache/$(echo -n $TIKTOKEN_URL_cl100k | sha1sum | head -c 40) $TIKTOKEN_URL_cl100k && \
    wget -O /opt/tiktoken_cache/$(echo -n $TIKTOKEN_URL_o200k | sha1sum | head -c 40) $TIKTOKEN_URL_o200k

ENV TIKTOKEN_CACHE_DIR=/opt/tiktoken_cache

# Set the working directory
WORKDIR /home/site/wwwroot

COPY ./requirements.txt requirements.txt

RUN pip install -r ./requirements.txt

# Copy the package.json
COPY . .

# Expose the port the app runs on
EXPOSE 6000

# Run the application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "6000"]
# Use the official Python image from Microsoft for Azure App Service
FROM mcr.microsoft.com/devcontainers/python:3.12

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
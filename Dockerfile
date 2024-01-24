# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container to /app
WORKDIR /app

# Install Poetry
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python \
    && ln -s $HOME/.poetry/bin/poetry /usr/local/bin/poetry \
    && apt-get remove -y curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -f install cron

# Copy the Python script and poetry files (pyproject.toml, poetry.lock) into the container at /app
COPY main.py pyproject.toml poetry.lock crontab /app/

# Install project dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

### Enable this if you want to run this as a one off process
## Run ecs_service_discovery.py when the container launches
#CMD ["python", "./main.py"]

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/ecs-service-discovery-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/ecs-service-discovery-cron

# Apply cron job
RUN crontab /etc/cron.d/ecs-service-discovery-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log

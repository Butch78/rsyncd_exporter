# Use the latest Ubuntu image as the base
FROM ubuntu:latest

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    cron \
    rsync \
    curl \
    build-essential \  
    lld \
    libssl-dev

# Install Rust
RUN apt-get install -y curl
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create directories
RUN mkdir -p /usr/src/app/rsync_exporter
RUN mkdir -p /usr/src/app/rsync_exporter/exercise_root
RUN mkdir -p /usr/src/app/rsync_exporter/tmp

# Define working directory
WORKDIR /usr/src/app/rsync_exporter

# Copying files
COPY . /usr/src/app/rsync_exporter/
COPY cron_task /etc/cron.d/cron_task

# Execution permission
RUN chmod +x start_rsync_pipeline.sh
RUN chmod +x generate_logs.sh
RUN chmod +x /etc/cron.d/cron_task

# Cronjob into the cron table
RUN crontab /etc/cron.d/cron_task

# Build the Rust application
RUN cargo build --release

# Exposing port
EXPOSE 8080

# Entry point
ENTRYPOINT ["./start_rsync_pipeline.sh"]
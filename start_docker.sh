#!/bin/bash -e

# Function to create a symbolic link if it doesn't already exist
create_symlink_if_not_exist() {
    local target=$1
    local link=$2

    if [ ! -L "$link" ]; then
        ln -s "$target" "$link"
    fi
}

# Creating necessary symbolic links
create_symlink_if_not_exist LLM_training_docker/Dockerfile ./Dockerfile
create_symlink_if_not_exist LLM_training_docker/docker-compose.yml ./docker-compose.yml
create_symlink_if_not_exist LLM_training_docker/config/.env.example ./.env

# Setting user and group information
USER_ID=${USER_ID:-$(id -u)}
GROUP_ID=${GROUP_ID:-$(id -g)}
USER_NAME=${USER_NAME:-${USER}}

# Color definitions
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Displaying current user and group information
echo -e "${GREEN}+-------------------+-------------+"
echo -e "|     Attribute     |    Value    |"
echo -e "+-------------------+-------------+"
printf "| %-17s | %-11s |\n" "Current USER_ID" "$USER_ID"
printf "| %-17s | %-11s |\n" "Current GROUP_ID" "$GROUP_ID"
printf "| %-17s | %-11s |\n" "Current USER_NAME" "$USER_NAME"
echo -e "+-------------------+-------------+${NC}"

# Setting service name and converting it to lowercase
SERVICE_NAME="llm_train_env_${USER_NAME,,}_2"

# If the argument is 'log', display logs and exit
if [ "$1" = "log" ]; then
    docker logs $SERVICE_NAME
    exit 0
fi

# Checking if the Docker service is running
if [ $(docker ps --filter "name=$SERVICE_NAME" --filter "status=running" -q | wc -l) -gt 0 ]; then
    docker exec -it $SERVICE_NAME /bin/bash
else
    USER_ID=$USER_ID GROUP_ID=$GROUP_ID USER_NAME=$USER_NAME SERVICE_NAME=$SERVICE_NAME docker compose up --build -d
    sleep 1
    docker logs $SERVICE_NAME
fi

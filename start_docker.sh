#!/bin/bash -e

USE_SUDO=$1

# Color definitions
GREEN='\033[0;32m'
NC='\033[0m' # No Color


if [ "$USE_SUDO" = "su" ]; then
    echo -e "${GREEN}[+] Use sudo docker${NC}"
fi

# Function to create a symbolic link if it doesn't already exist
create_symlink_if_not_exist() {
    local target=$1
    local link=$2

    if [ ! -L "$link" ]; then
        ln -s "$target" "$link"
    fi
}

use_docker() {
    if [ "$USE_SUDO" = "su" ]; then
        sudo docker "$@"
    else
        docker "$@"
    fi
}

# Creating necessary symbolic links
create_symlink_if_not_exist LLM_training_docker/Dockerfile ./Dockerfile
create_symlink_if_not_exist LLM_training_docker/docker-compose.yml ./docker-compose.yml
# create_symlink_if_not_exist LLM_training_docker/config/.env.example ./.env

# Setting user and group information
USER_ID=${USER_ID:-$(id -u)}
GROUP_ID=${GROUP_ID:-$(id -g)}
USER_NAME=${USER_NAME:-${USER}}

# Displaying current user and group information
echo -e "${GREEN}+-------------------+-------------+"
echo -e "|     Attribute     |    Value    |"
echo -e "+-------------------+-------------+"
printf "| %-17s | %-11s |\n" "Current USER_ID" "$USER_ID"
printf "| %-17s | %-11s |\n" "Current GROUP_ID" "$GROUP_ID"
printf "| %-17s | %-11s |\n" "Current USER_NAME" "$USER_NAME"
echo -e "+-------------------+-------------+${NC}"

# Setting service name and converting it to lowercase
SERVICE_NAME="llm_train_env_${USER_NAME,,}"

# If the argument is 'log', display logs and exit
if [ "$USE_SUDO" = "su" ]; then
    if [ "$2" = "log" ]; then
        use_docker logs $SERVICE_NAME
        exit 0
    fi
elif [ "$1" = "log" ]; then
    use_docker logs $SERVICE_NAME
    exit 0
fi

# Checking if the Docker service is running
if [ $(use_docker ps --filter "name=$SERVICE_NAME" --filter "status=running" -q | wc -l) -gt 0 ]; then
    use_docker exec -it $SERVICE_NAME /bin/bash
elif [ "$USE_SUDO" = "su" ]; then
    echo -e "use_docker compose up --build -d"
    cp LLM_training_docker/config/.env.example .env
    cat <<EOF >> .env
# <Start of TMP>
USER_ID=${USER_ID}
GROUP_ID=${GROUP_ID}
USER_NAME=${USER_NAME}
SERVICE_NAME=${SERVICE_NAME}
# <End of TMP>
EOF
    use_docker compose up --build -d
    sleep 1
    use_docker logs $SERVICE_NAME
    sed -i '/# <Start of TMP>/,/# <End of TMP>/d' .env
else
    echo -e "USER_ID=$USER_ID GROUP_ID=$GROUP_ID USER_NAME=$USER_NAME SERVICE_NAME=$SERVICE_NAME use_docker compose up --build -d"
    cp LLM_training_docker/config/.env.example .env
    USER_ID=$USER_ID GROUP_ID=$GROUP_ID USER_NAME=$USER_NAME SERVICE_NAME=$SERVICE_NAME use_docker compose up --build -d
    sleep 1
    use_docker logs $SERVICE_NAME
fi

# LLM_training_docker

## How to run
```bash
cd LLM_training_docker
chmod +x start_docker.sh
cd ..
```

```bash
ln -s LLM_training_docker/start_docker.sh start_docker.sh
./start_docker.sh
```

## If you not in docker group, try 
```
USER_ID=$(id -u) GROUP_ID=$(id -g) USER_NAME=${USER} sudo -E ./start_docker.sh
```

## Stop service

```bash
docker compose down
```
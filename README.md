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

## If you not in docker group
```bash
USER_ID=$(id -u) GROUP_ID=$(id -g) USER_NAME=${USER} sudo -E ./start_docker.sh
```
If still no work, try it
```bash
./start_docker.sh su
```

## Stop service

```bash
docker compose down
```

## Print log
```bash
./start_docker.sh log
```
If you use `./start_docker.sh su` run docker container, use 
```bash
./start_docker.sh su log
```


### Troubleshooting

If you `/home/docker/.cache/huggingface PermissionError: [Errno 13] Permission denied` problem, try comment `docker-compose.yml` volumes `~/.cache/huggingface:/home/docker/.cache/huggingface`.

### TODO
- [ ] Write script args
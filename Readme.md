## Remember to cd in to the project directory before you run this command
docker-compose run --rm app chown -R $(id -u):$(id -g) .

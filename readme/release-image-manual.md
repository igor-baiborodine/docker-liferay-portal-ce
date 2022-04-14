## How to Release Image 7.4.3.20-ga20 

### Docker command aliases:
```shell
## Docker
alias dsp='docker system prune'

# Image
alias dip='docker image prune'
alias dils='docker image ls'
alias dirm='docker image rm'

# Container
alias dcp='docker container prune'
alias dcla='docker container ls -a'
alias dci='docker container inspect'
alias dcs='docker container stop'
alias dcr='docker container rm'
# stop all containers
alias dcsa='docker container stop $(docker ps -a -q)'
# remove all containers
alias dcra='docker container rm $(docker ps -a -q)'
```

### Dry Run
Clone the project to your local dev:
```shell
git clone https://github.com/igor-baiborodine/docker-liferay-portal-ce.git
cd docker-liferay-portal-ce
```

Release images in dry-run mode:
```shell
$ script/dry-run.sh -t 7.4.3.20-ga20/jdk8-alpine
$ script/dry-run.sh -t 7.4.3.20-ga20/jdk8-bullseye
$ script/dry-run.sh -t 7.4.3.20-ga20/jdk11-bullseye
```

The `dry-run` folder should look like below:
```shell
$ tree -La 3 dry-run
dry-run
├── 7.4.3.20-ga20
│   ├── jdk11-bullseye
│   │   ├── docker-entrypoint.sh
│   │   └── Dockerfile
│   ├── jdk8-alpine
│   │   ├── docker-entrypoint.sh
│   │   └── Dockerfile
│   └── jdk8-bullseye
│       ├── docker-entrypoint.sh
│       └── Dockerfile
├── README.md
├── supported-tags
```

Build images for each corresponding Dockerfile:
```shell
$ docker build --rm -t dr-7.4.3.20-ga20-jdk8-alpine dry-run/7.4.3.20-ga20/jdk8-alpine
$ docker build --rm -t dr-7.4.3.20-ga20-jdk8-bullseye dry-run/7.4.3.20-ga20/jdk8-bullseye
$ docker build --rm -t dr-7.4.3.20-ga20-jdk11-bullseye dry-run/7.4.3.20-ga20/jdk11-bullseye
```

List images:
```shell
$ dils
REPOSITORY                       TAG                      IMAGE ID            CREATED             SIZE
dr-7.4.3.20-ga20-jdk11-bullseye    latest                   2c6570687d76        2 days ago          1.46GB
dr-7.4.3.20-ga20-jdk8-bullseye     latest                   99c737b17e72        2 days ago          1.35GB
dr-7.4.3.20-ga20-jdk8-alpine       latest                   62f046fa8a17        2 days ago          954MB
```

Run a container with the corresponding use case for each locally built image and test a Liferay Portal instance at `http://localhost:80`:
```shell
$ script/run-container.sh -t dr-7.4.3.20-ga20-jdk8-alpine -u base
$ script/run-container.sh -t dr-7.4.3.20-ga20-jdk8-bullseye -u base
$ script/run-container.sh -t dr-7.4.3.20-ga20-jdk11-bullseye -u base
```

Verify logs:
```shell
$ docker logs -f test-base
```

Stop and remove all containers:
```shell
$ dcsa && dcra
```

### Release Images

Release images and publish them to Docker Hub; repeat for each tag variant: 
1. `7.4.3.20-ga20/jdk8-alpine`
2. `7.4.3.20-ga20/jdk8-bullseye`
3. `7.4.3.20-ga20/jdk11-bullseye` 

* In GitHub, select the `Perform Release` workflow in the `Actions` tab.
* Click on the `Run workflow` and enter the tag variant in the `Release Version` field.
* Click on the `Run workflow` below the `Release Version` field and wait until the execution is completed.

Pull images from Docker Hub:
```shell
$ docker pull ibaiborodine/liferay-portal-ce:7.4.3.20-ga20-jdk8-alpine
$ docker pull ibaiborodine/liferay-portal-ce:7.4.3.20-ga20-jdk8-bullseye
$ docker pull ibaiborodine/liferay-portal-ce:7.4.3.20-ga20-jdk11-bullseye
```

Run a container with the corresponding use case for each image pulled from Docker Hub and test Liferay Portal:
```shell
$ script/run-container.sh -t ibaiborodine/liferay-portal-ce:7.4.3.20-ga20-jdk8-alpine -u extended
$ script/run-container.sh -t ibaiborodine/liferay-portal-ce:7.4.3.20-ga20-jdk8-bullseye -u extended
$ script/run-container.sh -t ibaiborodine/liferay-portal-ce:7.4.3.20-ga20-jdk11-bullseye -u extended
```

Verify logs:
```shell
$ docker logs -f test-extended
```

Stop and remove all containers:
```shell
$ dcsa && dcra
```

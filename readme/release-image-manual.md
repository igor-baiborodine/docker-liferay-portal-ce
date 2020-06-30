### How to Release an Image 

Docker command aliases:
```shell script
## Docker
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

Clone the project to your local dev:
```shell script
git clone https://github.com/igor-baiborodine/docker-liferay-portal-ce.git
cd docker-liferay-portal-ce
```

Release images in dry-run mode:
```shell script
script/dry-run.sh -t 7.3.2-ga3/jdk8-alpine
script/dry-run.sh -t 7.3.2-ga3/jdk8-buster
script/dry-run.sh -t 7.3.2-ga3/jdk11-buster
```

The `dry-run` folder should look like below:
```shell script
$ tree -La 3 dry-run
dry-run
├── 7.3.2-ga3
│   ├── jdk11-buster
│   │   ├── docker-entrypoint.sh
│   │   └── Dockerfile
│   ├── jdk8-alpine
│   │   ├── docker-entrypoint.sh
│   │   └── Dockerfile
│   └── jdk8-buster
│       ├── docker-entrypoint.sh
│       └── Dockerfile
├── README.md
├── supported-tags
└── .travis.yml
```

Build images for each corresponding Dockerfile:
```shell script
docker build --rm -t dr-7.3.2-ga3-jdk8-alpine dry-run/7.3.2-ga3/jdk8-alpine
docker build --rm -t dr-7.3.2-ga3-jdk8-alpine dry-run/7.3.2-ga3/jdk8-buster
docker build --rm -t dr-7.3.2-ga3-jdk8-alpine dry-run/7.3.2-ga3/jdk11-buster
```

List images:
```shell script
$ dils
REPOSITORY                       TAG                      IMAGE ID            CREATED             SIZE
dr-7.3.2-ga3-jdk11-buster        latest                   2c6570687d76        9 days ago          1.46GB
dr-7.3.2-ga3-jdk8-buster         latest                   99c737b17e72        9 days ago          1.35GB
dr-7.3.2-ga3-jdk8-alpine         latest                   62f046fa8a17        9 days ago          954MB
```

Run a container with the corresponding use case for each locally built image and test Liferay Portal:
```shell script
$ script/run-container.sh -t dr-7.3.2-ga3-jdk8-alpine -u base
$ script/run-container.sh -t dr-7.3.2-ga3-jdk11-buster -u tomcat-version
$ script/run-container.sh -t dr-7.3.2-ga3-jdk11-buster -u deploy -v ~/temp/liferay/docker/test
```

Stop and remove all containers:
```shell script
$ dcsa && dcra
```

Release images and publish them to Docker Hub:
```shell script
$ script/release-image.sh -t 7.3.2-ga3/jdk8-alpine
$ git pull
$ script/release-image.sh -t 7.3.2-ga3/jdk8-buster
$ git pull
$ script/release-image.sh -t 7.3.2-ga3/jdk11-buster
$ git pull
```

Pull images from Docker Hub:
```shell script
$ docker pull ibaiborodine/liferay-portal-ce:7.3.2-ga3-jdk8-alpine
$ docker pull ibaiborodine/liferay-portal-ce:7.3.2-ga3-jdk8-buster
$ docker pull ibaiborodine/liferay-portal-ce:7.3.2-ga3-jdk11-alpine
```

Run a container with the corresponding use case for each image pulled from Docker Hub and test Liferay Portal:
```shell script
$ script/run-container.sh -t ibaiborodine/liferay-portal-ce:7.3.2-ga3-jdk8-alpine -u base
$ script/run-container.sh -t ibaiborodine/liferay-portal-ce:7.3.2-ga3-jdk8-buster -u extended
$ script/run-container.sh -t ibaiborodine/liferay-portal-ce:7.3.2-ga3-jdk11-buster -u deploy -v ~/temp/liferay/docker/test
```

Stop and remove all containers:
```shell script
$ dcsa && dcra
```

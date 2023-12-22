**[Course](../README.md)**
&emsp;[Study materials](#study-materials)
&emsp;[Homework assignment](./homework/README.md)

# Docker compose

**Use groups of containers as a whole**

Hello and welcome to the Docker couse and its final learning session devoted to Docker Compose.

Today we are going to see how to use the tool on several examples. We will examine common problems in its usage. Unfortunately we will not able to cover all aspects of Docker Compose, but the things we will discuss today is a good foundation you can build your knowledge on.

Docker Compose is a tool for defining and running multi-container Docker applications. With Docker Compose, we use a [YAML] file to configure our application's services. Then, with a single command, we create and start all the services from the configuration.

[YAML] is a human-readable data serialization language that is often used for writing configuration files.

The [YAML] file we use for Docker Compose defines services and other components that make up an application so the Docker Compose can run these components together in an isolated environment.

Let' see it on examples.

## Minimal

As usual, we start from a minimal but logically complete example.

```sh
cd minimal
```

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3.0'
services:
  busybox:
    image: busybox
```

Services is a main section of any `docker-compose.yaml` file under which we define components of our application.

In the file we declare one service named `busybox`. For a service we can use any name. But there can be only one declaration for a service with particular name.

For the service we use container image named `busybox`.

Let's run a container using the [docker compose up] command.

```sh
docker-compose up
```
>```
>[+] Running 2/2
> ✔ Network minimal_default       Created                                                                           0.4s
> ✔ Container minimal-busybox-1  Created                                                                           0.2s
>Attaching to busybox-1
>busybox-1 exited with code 0
>```

By default Docker Compose reads configuration from `docker-compose.yaml` file in current working directory. This can be changed by means of `--file` option.

The command has created container from specified image ran it and waited till its completion. The command also pulls or builds an image if it doesn't exist in local container image registry yet.

This command is equal to the [docker run] command whithout attaching our terminal to the container. That's why container has terminated immediately after it has started.

Pay attention to the names the command used. We see container name is `minimal-busybox-1`. The prefix is the name of the directory our `docker-compose.yaml` file resides in. Suffix `1` means the conainer is the first container for the service. So a container name gets built from directory name, service name and container number.

We see there is also a network has been created. The Docker Compose creates one default network and attaches all the container it starts to this network. We will see later how it gets used in connainers communication.

Let's try [docker compose run] command.

```sh
docker-compose run busybox
```

For the run command we have to specify name of the service.
Actually the [docker compose run] command runs a one-off command on a service. And it allows to specify the command with its arguments. This is equal to [docker exec] command, except it creates a container for a service if it does not exist yet. If we do not specify any command, then it uses container image default one, which in our case is a command that starts linux shell.

Let's exit from the shell.

```sh
exit
```

## Terminal

Despite that the Docker Compose is intended to manage multi-container applications, using it even for a single container scenario can be useful.

For instance, we might need a working environment that requires different tools to be installed. We can create a `Dockerfile` that will define a container having all the tools installed, and a `docker-compose.yaml` file allowing to start the environment by a single command. Let's see an example of this.

```sh
cd ../terminal
```

Here is our `Dockerfile`.

```sh
cat Dockerfile
```
```Dockerfile
FROM alpine

RUN \
  apk update --no-cache \
  && apk add --no-cache figlet \
  && apk add --no-cache cowsay \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
```

The file has a [RUN] instruction that installs required tools. For demonstation we use `figlet` and `cowsay` utilities.

Then we have the following `docker-compose.yaml`.

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3.0'
services:
  terminal:
    build: .
    volumes:
    - .:/workspace
    working_dir: /workspace
    command:
    - sh
    - -c
    - |
      echo Welcome to Terminal | figlet -fmini
      sh
```

Instead of an `image` section we have a `build` section wich declares a Docker context that will be used to build an image. We use current directory here. To build an image Docker Context will read Dockerfile resides in the docker context directory. The path to the Dockerfile can also be specified in docker-compose file.

Then we have a `volumes` section using which we attach our current directory to `workspace` directory inside a container. And for convinience we declare a container's working dir to refer to that directory, so a container will start with our host current directory as its own current directory.

Then we have a command section. Here we can define a command that will be executed when we start the environment using [docker compose run] command. It can be a simple command or a script that will do some initialization. In our example it prints out a welcome message.

Let's start the working environment.

```sh
docker-compose run terminal
```

Now we are inside the working environment which has all the tools we need. So let's try them.

```sh
cowsay I love Docker Compose!
```

Since we have attached our host working dir to the container, then we can use files reside in the host working directory.

Let's ask the cow to read our `docker-compose.yaml` file.

```sh
cat docker-compose.yaml | cowsay -W50
```

It works as expected and we can exit the environment.

```sh
exit
```

Here is a real-life example of `docker-compose.yaml` file that uses this technique.

```sh
cat real-example.yaml | yq
```
```yaml
services:
  runner:
    build:
      context: .
      dockerfile: Dockerfile
    image: organization.net/images/devops-tools-helm-job-runner
    volumes:
    - .:/var/workspace:rw
    - ~/.aws:/home/default/.aws:ro
    - ~/.kube:/home/default/.kube:ro
    - ~/.ssh:/home/default/.ssh:ro
```

Here we have a `build` section and an `image` section together. This way we can specify an image name that will be used when Docker Compose builds an image.

Then under `volume` section we have a bunch of mounts. We mount our current directory as a `workspace` with write access and all other mounts have a read only access.

## Multi container

And now let's look at multi-container application examples.

```sh
cd ../multi-first
```

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3.0'
services:
  producer:
    image: busybox
    command:
    - sh
    - -c
    - |
      sleep 1
      echo hello | nc -v -l -p 54321
  consumer:
    image: busybox
    command:
    - sh
    - -c
    - nc -v producer 54321
```

In this `docker-compose.yaml` we define two services named `producer` and `consumer`. The role of `producer` is to provide some data publishing it via network port `54321`, so any `consumer` can connect to it and retrieve the data.

For a sake of simplicity we do not define a Dockerfile for each of the service but use existing busybox container image and define services's logic via shell scripts written in the `command` sections.

The `producer` does not start listening to the port immediately after its start but waits one second before. It emulates a delay which often happens in real life applications. 

We expect that once the `consumer` is connected to the `producer` it will get the `hello` message and the application will terminate successfully.

Let's launch our application.

```sh
docker-compose up
```
>```
>[+] Running 2/2
> ✔ Container multi-first-consumer-1  Created                                                                                               0.2s
> ✔ Container multi-first-producer-1  Created                                                                                               0.2s
> Attaching to consumer-1, producer-1
>consumer-1 exited with code 1
>producer-1  | listening on [::]:54321 ...
>```

We see that the `consumer` exited with code 1, meaning there was an error.
And the `producer` keeps listening to the port, meaning it was not connected.

This happened because by default Docker Compose starts all conainers defined in a docker-compose file at once.

So in our example the `consumer` container was started together with the `producer` container and while `producer` was in delay, the `consumer` tried to connect but failed.

Let's prove it by running the containers separately starting from the `producer`.

```sh
docker-compose up --detach producer
```
>```
>[+] Running 1/1
> ✔ Container multi-first-producer-1  Started
>```

We use `--detached` option of the [docker compose up] command to run the container in background without attaching our terminal to it.

Let's run the `consumer` container then.

```sh
docker-compose up consumer
```
>```
>[+] Running 1/0
> ✔ Container multi-first-consumer-1  Created                                                                                               0.0s
>Attaching to consumer-1
>consumer-1  | producer (172.18.0.2:54321) open
>consumer-1  | hello
>consumer-1 exited with code 0
>```

So when the `consumer` get started after the `consumer` we got a correct behaviour.

Can we control the order of starting containers and thus guarantee required behaviour using Docker Compose?

Yes, we can and let's see how.

```sh
cd ../multi-second
```

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3.0'
services:
  producer:
    image: busybox
    command:
    - sh
    - -c
    - |
      sleep 1
      echo hello | nc -v -l -p 54321
  consumer:
    image: busybox
    command:
    - sh
    - -c
    - nc -v producer 54321
    depends_on:
    - producer
```

The simplest way to achieve our goal is to declare a service dependency under `depends_on` section. Under the section we list services the particular service is depending on.

Let's run the services.

```sh
docker compose up
```
>```
>[+] Running 2/2
> ✔ Container multi-third-producer-1  Created                                                                                             0.2s
> ✔ Container multi-third-consumer-1  Created                                                                                             0.2s
>Attaching to consumer-1, producer-1
>producer-1  | listening on [::]:54321 ...
>producer-1  | connect to [::ffff:172.22.0.2]:54321 from multi-third-consumer-1.multi-third_default:42435 ([::ffff:172.22.0.3]:42435)
>consumer-1  | producer (172.22.0.2:54321) open
>consumer-1  | hello
>consumer-1 exited with code 0
>producer-1 exited with code 0
>```

Now it wokrs as expected. The `consumer` container get started only after `producer` got started.

But frankly speaking, the solution is incomplete and fragile. Let's see why it is so. 

```sh
cd ../multi-third
```

```sh
cat failing.yaml | yq
```
```yaml
version: '3.0'
services:
  producer:
    image: busybox
    command:
    - sh
    - -c
    - |
      sleep 2
      echo hello | nc -v -l -p 54321
  consumer:
    image: busybox
    command:
    - sh
    - -c
    - nc -v producer 54321
    depends_on:
    - producer
```

We increased the time interval the `producer` waits before listening to the port by one extra second. Let's see how it will affect our application.

```sh
docker-compose --file failing.yaml up
```

The issue is back.

So we need a better way to determine when the `producer` container is ready to receive connections.

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3.0'
services:
  producer:
    image: busybox
    command:
    - sh
    - -c
    - |
      sleep 3
      while true; do
        echo hello | nc -v -l -p 54321
      done
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "54321"]
      interval: 5s
  consumer:
    image: busybox
    command:
    - sh
    - -c
    - nc -v producer 54321
    depends_on:
      producer:
        condition: service_healthy
```

The Docker Compose has special section named `healthcheck` that defines a command that the Docker Compose will execute periodicaly to determine if a container is healthy. And it also provides a condition that can be used in the `depends_on` section.

In our example we use `natcat` tool to scan the port. So once there is a process listening to the port the tool reports success and the Docker Compose considers the service healthy. Otherwise the `netcat` fails and the check process repeats.

According to specified interval, the health check will first run 5 seconds after the `producer` container is started, and then again 5 seconds after each previous check completes.
Once the `producer` container is in healthy status, then the `consumer` container is being started.

Let's run the application using this new docker-compose file.

```sh
docker-compose up
```
>```
>[+] Running 2/2
> ✔ Container multi-third-producer-1  Created                                                                                             0.2s
> ✔ Container multi-third-consumer-1  Created                                                                                             0.2s
>Attaching to consumer-1, producer-1
>producer-1  | listening on [::]:54321 ...
>producer-1  | connect to [::ffff:127.0.0.1]:54321 from localhost:37225 ([::ffff:127.0.0.1]:37225)
>producer-1  | listening on [::]:54321 ...
>producer-1  | connect to [::ffff:172.27.0.2]:54321 from multi-third-consumer-1.multi-third_default:40089 ([::ffff:172.27.0.3]:40089)
>consumer-1  | producer (172.27.0.2:54321) open
>consumer-1  | hello
>producer-1  | listening on [::]:54321 ...
>consumer-1 exited with code 0
>```

Everything works again.

## Dockerfile healthcheck

Actually, there is the [HEALTHCHECK] instruction we can use in a Dockerfile. Let's try our solution using this instruction.

```sh
cd ../healthcheck
```

```sh
cat Dockerfile
```
```Dockerfile
FROM busybox

COPY entrypoint.sh .

HEALTHCHECK --interval=5s CMD [ "nc", "-z", "localhost", "54321" ]

ENTRYPOINT [ "sh", "entrypoint.sh" ]
```

The syntax is preatty much the same we us in Docker Compose.

Since we have a Docker file for our `producer` service we can remove its script from `docker-compose.yaml` file and put it into `entrypoint.sh` script we use as the image entrypoint.

```sh
cat entrypoint.sh
```
```shell
while true
do
  echo you have reached $(hostname) | nc -l -p 54321
done
```

Let's look at the `docker-compose.yaml` file.

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3.0'
services:
  producer:
    build: .
  consumer:
    image: busybox
    command:
    - sh
    - -c
    - nc producer 54321
    depends_on:
      producer:
        condition: service_healthy
```

The new file is much more concise.

Let's launch the application.

```sh
docker-compose up
```

We removed all the diagnostic messages we used in the previous examples. But as you can see the `consumer` has connected to the `producer` and got data from it. So it works as we expected.

## Scaling

Using Docker Compose we can not only start multiple services but also have multiple containers for each service. Let's see how easy it can be done.

```sh
cd ../scaling
```

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3.0'
services:
  producer:
    build: .
    deploy:
      replicas: 3
  consumer:
    image: busybox
    command:
    - sh
    - -c
    - nc producer 54321
    depends_on:
      producer:
        condition: service_healthy
    deploy:
      replicas: 8
```

All thet we need is to add `deploy` section and define a number of `replicas` we need for each service.

```sh
docker-compose up
```

It is possible to change number of containers whithout modification of the `docker-compose.yaml` file.

```sh
docker-compose up --scale producer=1 --scale consumer=3
```

## Transitive dependency

```sh
cd ../transitive
```

```sh
cat docker-compose.yaml | yq
```
```yaml
version: '3'
services:
  board:
    build:
      dockerfile: Dockerfile.board
  init:
    build:
      dockerfile: Dockerfile.init
    depends_on:
      board:
        condition: service_healthy
  applicant:
    build:
      dockerfile: Dockerfile.applicant
    depends_on:
      init:
        condition: service_completed_successfully
    deploy:
      replicas: 2
```

# Epilogue

Today we have acquainted with Docker Compose and the docker-compose file syntax. We started from a simple example, then we saw how to use Docker Compose to create a development environment with a single container. We reviewed several multi container application examples. We examined in detail the solution to the problem of starting services in a certain order using service dependencies.

Docker Compose is a much broader topic which is worth of distinct course. We have literally only scratched a surface of Docker Compose.

[docker compose run]: https://docs.docker.com/engine/reference/commandline/compose_run/
[docker compose up]: https://docs.docker.com/engine/reference/commandline/compose_up/
[docker exec]: https://docs.docker.com/engine/reference/commandline/exec/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/
[HEALTHCHECK]: https://docs.docker.com/engine/reference/builder/#healthcheck
[RUN]: https://docs.docker.com/engine/reference/builder/#run
[YAML]: https://en.wikipedia.org/wiki/YAML

---
**[Top](#)**
&emsp;[Course](/README.md)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

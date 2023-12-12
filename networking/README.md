**[Course](../README.md)**
&emsp;[Study materials](#study-materials)
&emsp;[Homework assignment](./homework/README.md)

# Networking

**Hands on on docker networking**

Hello everyone and welcome to Docker course and its next learning session devoted to networking.

Today we are going to see how networking works in Docker, what options it provides to us for managing communications between containers, our Docker host, and the outside world.

For demostations we will use the `netcat` (nc) tool, which is a command-line utility for reading and writing data between two computer network endpoints.

So let's move on to our today's session topic.

## Container network model

![Container network model](https://14738011-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-MCkNUw3Li8vYWxtVPS9%2F-MDi0O1rUFC8XJYSha1s%2F-MDiAbuy2dkqLnJdLdF3%2Fnetwork-cnm.jpg?alt=media&token=707fb0f5-cb2c-4231-90c6-941d03f62fa9)

Container networking refers to the ability for containers to connect to and communicate with each other, or to non-Docker workloads. The Docker network is a virtual network created by Docker to enable this communication.

We can define Docker Networking as a communication passage through which all the isolated containers communicate with each other in various situations to perform the required actions.

## Default networks

Network is another kind of resources in Docker. 
We can list networks by means of [docker network list] command.

```sh
docker network list
```
>```
>NETWORK ID     NAME      DRIVER    SCOPE
>a02be1bb7cf6   bridge    bridge    local
>84d99c540a8c   host      host      local
>575e8b6addb3   none      null      local
>```

We see that there is a set of built-in networks already present in our Docker system.

The `bridge` network is the network all newly created containers attached to by default.

The `host` network is used whe we want our containers be accessed on the host’s IP address.

The `none` network is used when we don't want any network interface for our containers. Setting a container’s network to `none` will completely disable its networking stack. The container will be unable to reach its neighbors, our host’s services, or the internet. This helps improve security by sandboxing applications that aren’t expected to require connectivity.

## Host network

![host networking](https://k21academy.com/wp-content/uploads/2020/06/bridge2.png)

Let's try the docker networking on example by running container that binds to a port and uses host network.

A port in computer networking is how a computer can use a single physical network connection to handle many incoming and outgoing connections.
Each port is associated with a specific process or service, or container in our case.
There is a set of port numbers reserved for particular services.
For our example we use number from so called `dynamic ports` range. Numbers from the range are used for temporary or private ports.

We are going to use `netcat` tool in the following simple script.
```sh
cat hostnetwork/node.sh
```
```sh
echo Hello, Network! | nc -l -p 54321
```

The script asks `netcat` to listen on port `54321` and sends `Hello, Network!` to one who's got connected. Once it is done the script exits.

We need a Dockerfile that defines an image to run the script.

```sh
cat hostnetwork/Dockerfile
```
```Dockerfile
FROM busybox

COPY node.sh .

ENTRYPOINT [ "sh", "node.sh" ]
```

We use `busybox` base image. As we already know, the image contains only a minimal set of common linux utilities, and the `netcat` utility is one of those.

Let's build an image.

```sh
docker build hostnetwork --tag node
```

Let's run a container attached the built-in `host` network.

```sh
docker run --rm --detach --network host node
```

We use `--detach` flag to inform Docker not to wait for the container completion and return control to our terminal. Otherwise we would wait until something gets connected to the container port and would not be able to call other commands.

To select network we use `--network` option and provide the network name.
When we use the `host` network, the container shares the host's networking namespace, and the container doesn't get its own IP-address allocated.

We run the container which binds to port `54321` and we use host networking, meaning the container's application is available on port `54321` on the host's IP address.

Let's try to connect to the running container.

When there is `netcat` utility available on the host machine we can use it.

```sh
nc localhost 54321
```

The connection was successfully established and we received the greetings message.

We can also try to connect using a web browser.
Let's start a new container but this time not using `--detach` option.

```sh
docker run --rm --network host node
```

Now we can connect to `localhost:54321` using web browser.

Host networks are best when we want to bind ports directly to your host’s interfaces and aren’t concerned about network isolation. They allow containerized applications to function similarly to network services running directly on our host.

## Bridge network

![bridge networking](https://k21academy.com/wp-content/uploads/2020/06/bmExZyvGWidultcwx9hCb7nTzqrqzN7Y9aBZTaXoQ8Q-1024x955.png)

An external system that has access to our host system can access a container running on the host system and attached to host's network.

We can not attach to our host network more than one container using the same port number, since all containers in the host network share a single network interface and a single IP-address. To do so we can use a `bridge` network that is isolated from host's machine networking stack and allocates a distinct virtual interface and IP-address for each container attached to the network.

Let's run a container with no network explicitly specified.

```sh
docker run --rm --detach node
```

If we look into container's configuration using `Lazydocker` or by means of [docker container inspect] command, under `Networks` section we would see that the container is attached to `bridge` network and has its IP-address.

We can not access the container from our host because it's attached to isolated network. But we can access it from within this network. Let's try this by running another container. We will use `netcat` tools so we will create a contanier from `busybox` image that has the tool.

Let's run a container in interactive terminal mode.

```sh
docker run --rm --interactive --tty busybox
```

Using `Lazydocker` we see that the container is also attached to `bridge` network and has its IP-address.

We can now connect the first container by its IP-address.

```sh
nc IP-address 54321
```

It works and we can exit from interactive session.

```sh
docker run --rm --detach node
```

In terms of Docker, a bridge network uses a software bridge which lets containers connected to the same bridge network communicate, while providing isolation from containers that aren't connected to that bridge network.

## Single network

Within the default bridge network only the assigned IP address can be used to communicate with other containers.

But the IP-address is what Docker dynamically assigns to containers and it doesn't keep the same adresses for same containers.

We can use the container name to connect from container to container as long as we have both containers on the same network and that network is not the default `bridge`.

So to communicate between containers using their names we have to use our own bridge network.
Let's see on examples how it works.

We are going to run two containers that will connect and communicate. For this purpose we will build two images containing special script each.

The script we will use for service is the following.

```sh
cat singlenetwork/service.sh
```
```sh
echo Thank you for choosing us! | nc -l -p 54321
```

The service waits for a connection on port `54321` and once it happened it sends the message back.

The script we will use for client also uses `netcat` utility.

```sh
cat singlenetwork/client.sh
```
```sh
echo hello | nc $HOST 54321
```

The client sends the message to a host presumably listening on port `54321`. We use `HOST` environment variable in the client script to be able to tweak the host name. The client does not check if connection with the host listening on required port is possible. So if there is no such host the script fails and exists.

We need a dockerfile to assemble images.

```sh
cat singlenetwork/Dockerfile
```
```Dockerfile
FROM busybox AS base

FROM base AS service

COPY service.sh .

ENTRYPOINT [ "sh", "service.sh" ]

FROM base AS client

COPY client.sh .

ENTRYPOINT [ "sh", "client.sh" ]
```

We use multi-stage builds here to consolidate two related image definitions. So we have two stages respectively named `service` and `client`.

Using `--taget` option of [docker build] command we can build image defined in `service` stage.

```sh
docker build singlenetwork --target service --tag service
```

The same way we build image defined in `client` stage.

```sh
docker build singlenetwork --target client --tag client
```

Then using [docker network create] command we create a new network named `party`.

```sh
docker network create party
```

We can see the network appeared in `Lazydocker` in the `Networks` section. And the network is a bridge network which is default option.

We can see all the network properties by using [docker network inspect] command.

```sh
docker network inspect party
```

Let's run a container from the service image. We know that by default the container will be connected to default `bridge` network which we don't want to happen. So we will use `--network` option and specify `party` as the name of the network we want the container to be attached to.

```sh
docker run --rm --detach --name gazda --network party service
```

The container is running and we see that `Lazydocker` shows it in the `party` network config.

Let's run a container from the client image in the same network providing name of the service container via `HOST` environment variable.

```sh
docker run --rm --env HOST=gazda --network party client
```

## Refer using container ID

We can also use 12 characters of the container id to establish connection between containers on the same non-default bridge network.

Let's start a service container again.

```sh
docker run --rm --detach --name gazda --network party service
```

Then connect to the service using its IP-address as value for the `HOST` environment variable.

```sh
docker run --rm --network party --env HOST=ID client
```

We done with the example and can delete the network. We can do it by [docker network rm] command that deletes an individual network or by [docker network prune] command that removes all custom networks not used by at least one container.

```sh
docker network prune --force
```

## Multiple networks

Actually, a container can be attached to multiple networks. Let's take a closer look into this.

We are going to see how one service can be present in several networks and can be connected by clients from these networks. To demonstrate this behaviour we need a bit more complex script for our service.

```sh
cat multinetwork/service.sh
```
```sh
response='Thank you for choosing us!'
request=$(echo $response | nc -v -l -p 54321)

while [ "$request" != "bye" ]; do
  response='Thank you for your request, we have already started working on it.'
  request=$(echo $response | nc -v -l -p 54321)
done
```

With the script a service won't exit once it got connected. It is constantly listening to port `54321` and reads a request from it. Then it sends a confirmation message back to the requestor. The process repeats until the request is `bye`.

We have added `-v` flag to the `netcat` command to turn on its verbose mode. In this mode utility prints out diagnostic messages. Thus, we will see what connected the service.

Here is a simple Dockerfile we use to build a service image.

```sh
cat multinetwork/Dockerfile
```
```Dockerfile
FROM busybox

COPY service.sh .

ENTRYPOINT [ "sh", "service.sh" ]
```

It copies `service.sh` and uses it as entrypoint.
Let's build an image.

```sh
docker build multinetwork --tag service
```

Let's create two networks.
```sh
docker network create party
docker network create batch
```

Now we can setup running service container with no network explicitly assigned.

```sh
docker run --rm --detach --name moderator service
```

The `moderator` container appeared in default network named `bridge`.
Let's connect the countainer to networks we have just created. Dispate the container was connected to default `bridge` network using [docker network connect] command we can additionaly connect it to another network.

```sh
docker network connect batch moderator
docker network connect party moderator
```

Now we see that both networks contain the `moderator` container.

By reviweing the container's configuration using `lazydocker`, we see all the connected networks are listed in the `Networks` section. The container has endpoint and IP address in each of the networks. It also has an alias which is equal to first 12 characters of the container ID for each network except the default `bridge`.

In the container's log we see the message saying that it is listening on port 54321.

>```
>listening on [::]:54321 ...
>```

Let's run a `busybox` container in the `party` network and connect to the `moderator` container also present in the `party` network.

```sh
docker run --rm --interactive --tty --network party busybox
```

We ran the container in interactive mode and now we at the container's command line prompt. We can use `netcat` tool to send a message to service running in `moderator` container and listening on port `54321`.

```sh
echo hello | nc moderator 54321
```

We see a greeting message, meaning we have connected to the service and received the message.

In the `moderator` container log we see that it got connected from the endpoint which has `party` in its name.

>```
>connect to [::ffff:172.24.0.2]:54321 from e163ae2f5556.party:39835 ([::ffff:172.24.0.3]:39835)
>listening on [::]:54321 ...
>```

Let's try the same scenario by running a busybox container in another network.
Since the first container is running in interactive mode we will use another terminal to run the second container.

```sh
docker run --rm --interactive --tty --network batch busybox
```

Using `netcat` we send another hello message from the second container.

```sh
echo hello | nc moderator 54321
```

We see no greeting message since the service prints it out only on first connection.

In the `moderator` container log we see new messages. And we see that the service was connected from another endpoint having `batch` in its name, meaning the endpoint from the `batch` network.

>```
>Thank you for your request, we have already started working on it.
>connect to [::ffff:172.25.0.2]:54321 from 32a2c2798289.batch:40409 ([::ffff:172.25.0.3]:40409)
>listening on [::]:54321 ...
>```

We can repeat requests from the running `busybox` containers and see the service correctly handles them.

Let's shutdown the service by sending `bye` request from one of the `busybox` containers.

```sh
echo bye | nc moderator 54321
```

The service container has completed and got removed from the list of containers.

And we can not connect to it anymore.

Let's exit from all the running busybox containers.

The `lazydocker` shows that there are no containers in networks we have created and in the default `bridge` network. We can delete networks by using [docker network prune] command.

```sh
docker network prune --force
```

Bridge networks are the most suitable option for the majority of scenarios we encounter. Containers in the network can communicate with each other using their own IP addresses and DNS names. They also have access to the host’s network, so they can reach the internet and the Local Area Ntetwork.

## Cross network

What if we have a scenario when there are containers attached to different networks but have to connect to each other?

Since bridge networks are isolated we can not directly connect across networks. Docker system drops such packages. Of course it is possible to tweak host machine IP tables and allow the packets pass through the barrier. But we will use another way.

For our experiment we need to build new `service` and `client` images.

For service we will use the same script as before.

```sh
port=54321
response='Thank you for choosing us!'
request=$(echo $response | nc -v -l -p $port)

while [ "$request" != "bye" ]; do
  response='Thank you for your request, we have already started working on it.'
  request=$(echo $response | nc -v -l -p $port)
done
```

For client we need a bit advanced script.

```sh
cat crossnetwork/client.sh
```
```sh
PORT=54321

while ! (nc -z $HOST $PORT); do
  sleep 1
done

echo Connection established.

echo hello | nc $HOST $PORT
echo bye | nc $HOST $PORT
```

The client script tries to connect to a host until it got connection. It tries to connect by issuing  `netcat` command every second.
Once connection established the script prints out confirmation message and sends to the connected host two messages, `hello` and `bye`.
According to the service script, once it received `bye` message it terminates.

We will use multi-stage Dockerfile that defines `service` and `client` stages.

```sh
cat crossnetwork/Dockerfile
```
```Dockerfile
FROM busybox AS base

FROM base AS service

COPY service.sh .

ENTRYPOINT [ "sh", "service.sh" ]

FROM base AS client

COPY client.sh .

ENTRYPOINT [ "sh", "client.sh" ]
```

On each stage it simply copies correspinding sript and set it as entrypoint. Let's build both images.

```sh
docker build crossnetwork --target service --tag service
docker build crossnetwork --target client --tag client
```

Then we have to create two networks.

```sh
docker network create black-eye
docker network create milky-way
```

In `lazydocker` we see these two new networks.

Let's run a container from `service` image connected to one of the two networks.

```sh
docker run --detach --name usg-ishimura --network black-eye service
```

Then we run a container from `client` image connected to another network.

```sh
docker run --detach --name usm-eudora --network milky-way --env HOST=usg-ishimura client
```

We didn't use `--rm` option in the [docker run] commands we used to create the containers, meaning the container will not be removed by Docker once they completed their runs. We did it intentionally to be able to review the containers logs.

Using environment variable `HOST` we specified name of a service the client should connect to.
As we see client works and tries to connect to the specified service.

In `Lazydocker` we see both containers are up and running. One is listening on the port. And the other is trying to connect to the first.

Let's create a third network.

```sh
docker network create warp
```

Using [docker network connect] command we can connect an existing container to an existing network. Let's try it by connecting first container.

```sh
docker network connect warp usg-ishimura
```

Nothing has changed from each container standpoint. They still can not connect to each other.
Let's connect second container to the network.

```sh
docker network connect warp usm-eudora
```

The connection established and containers have interchanged their messages. We can review the containers logs using `Lazydocker` or by means of the [docker logs] command.

```sh
docker logs usg-ishimura
```

```sh
docker logs usm-eudora
```

We can clean up containers.

```sh
docker container prune --force
```

And clean up networks

```sh
docker network prune --force
```

In our experiment we attached containers to networks that we have created. We can also detach a container from a network.
To disconnect a running container from a user-defined bridge, use the [docker network disconnect] command.

## Port publishing

Any container attached to an isolated bridge network can be also accessible from host network and so from external systems that can access the host. This can be achieved by publishing a container's port when we run a container.

```sh
docker run --rm --detach --publish 54321 node
```

Let's list running containers by using the [docker ps] command.

```sh
docker ps
```

In the port section we see some numbers point to our container's port. Docker picks any available port on the host system and map this port to the container's port. We can start another container by using the same command.

```sh
docker run --rm --detach --publish 54321 node
```

```sh
docker ps
```

Now we have two host ports mapped to the same port number. It is possible because each of the running containers has its own IP-address.

Let's connect to these ports.

```sh
nc localhost PORT
```

We successfully connected to each container via host ports. Each container sent greeting message and terminated.

We can map multiple host ports into the same container port. To do so we repeat `--publish` option several times.

```sh
docker run --rm --detach --publish 54321 --publish 54321 node
```

```sh
docker ps
```

We can connect to any of those ports.

```sh
nc localhost PORT
```

If we want to map a particular host port we can specify its number in `--publish` option the following way.

```sh
docker run --rm --detach --publish 80:54321 node
```

We can use the specified port to connect.

```sh
nc localhost 80
```

The [docker run] command has option `--publish-all`. It publishes all ports that a particular container is exposing, assigning available host port to each container port.

Lets use a script that listens on two different ports.

```sh
cat expose/node.sh
```
```sh
first=1; second=2
while [ "$first" -a "$second" ]; do sleep 1; done \
& first=$(echo You have connected to port 50001 | nc -l -p 50001) \
& second=$(echo You have connected to port 50002 | nc -l -p 50002)
```

It runs two `natcat` commands in parallel. Each command listens on its port and sends back its message.

Let's look into Dockerfile.

```sh
cat expose/Dockerfile
```
```Dockerfile
FROM busybox

COPY node.sh .

EXPOSE 50001 50002

ENTRYPOINT [ "sh", "node.sh" ]
```

Let's build an image and run a container from it.

```sh
docker build expose --tag expose
```

```sh
docker run --rm --detach --publish-all expose
```

Let's check our containers list.

```sh
docker ps
```

Now we can connect to each of assigned host ports and check the result.

```sh
nc localhost PORT
```

# Epilogue

On today's session we have seen how Docker networks function. We have covered the basics of using built-in and custom networks with container deployments, namely communication between containers connected to one network and communication between containers attached to different networks.

# Study materials

[Docker networking](https://capgemini.udemy.com/course/learn-docker/learn/lecture/7894034#overview)

[Docker Networking and Dockerizing Applications](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/16396228#overview)

# References

[What is a computer port? | Ports in networking](https://www.cloudflare.com/learning/network-layer/what-is-a-computer-port/)

[Docker Networking – Basics, Network Types & Examples](https://spacelift.io/blog/docker-networking)

[Docker Networking](https://borosan.gitbook.io/docker-handbook/docker-networking)

[How to Get A Docker Container IP Address - Explained with Examples](https://www.freecodecamp.org/news/how-to-get-a-docker-container-ip-address-explained-with-examples/)

[How to Use Netcat Commands: Examples and Cheat Sheets](https://www.varonis.com/blog/netcat-commands)

[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[docker container inspect]: https://docs.docker.com/engine/reference/commandline/container_inspect/
[docker logs]: https://docs.docker.com/engine/reference/commandline/logs/
[docker network connect]: https://docs.docker.com/engine/reference/commandline/network_connect/
[docker network create]: https://docs.docker.com/engine/reference/commandline/network_create/
[docker network disconnect]: https://docs.docker.com/engine/reference/commandline/network_disconnect/
[docker network inspect]: https://docs.docker.com/engine/reference/commandline/network_inspect/
[docker network list]: https://docs.docker.com/engine/reference/commandline/network_ls/
[docker network prune]: https://docs.docker.com/engine/reference/commandline/network_prune/
[docker network rm]: https://docs.docker.com/engine/reference/commandline/network_rm/
[docker ps]: https://docs.docker.com/engine/reference/commandline/ps/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/

---
**[Top](#)**
&emsp;[Course](/README.md)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

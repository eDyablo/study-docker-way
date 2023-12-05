**[Course](../README.md)**
&emsp;[Study materials](#study-materials)
&emsp;[Homework assignment](./homework/README.md)

# Build with dockerfile

**Be able to declaratively define a container image**

Hello everyone and welcome to the Docker course and its next learnig session.

Today we will create a container image using a Dockerfile.
We are going to start with a minimal but complete dockerfile and will modify it step by step fillіng it with content and meaning. The final image will define a container that can be run as an executable that prints out all arguments passed to it in ASCII art.

To demonstrate a result of actions we are going to do we will use `lazydocker` tool. It is a simple terminal UI that makes it easy to manage Docker, and also makes it easy to view logs, prune unused containers and images, and customize metrics.

From the introductory session we know that dockerfile is a text file provides a set of instructions to build a container image.

On the previous learning session we were building images using a set of docker specific commands we were calling in a certain order. In fact, Docker uses the same approach, it reads a dockerfile and runs corresponding commands.

Therefore Dockerfile is a text document containing all the commands the user requires to call on the command line to assemble an image. With the help of a Dockerfile, we can create an automated build that executes several command-line instructions in succession.

Let's write an absolutelly minimal but complete dockerfile.

```Dockerfile
FROM alpine
```

We use dockerfile instruction [FROM] and select the `alpine` image to be our base image. We do not add a registry or repository path or image tag to the image name, meaning our Docker engine will use default registry which is [Docker Hub] and default tag which is `latest`.

The definition we've wrote is structurally and logically complete and can be used to build our new container image.

To build an image from a Dockerfile we use the [docker build] command.

```sh
docker build .
```

Using `.` here we inform Docker that our Dockerfile resides in the current working directory.

>```
>Sending build context to Docker daemon  2.048kB
>Step 1/1 : FROM alpine
>latest: Pulling from library/alpine
>c926b61bad3b: Pull complete 
>Digest: sha256:34871e7290500828b39e22294660bee86d966bc0017544e848dd9a255cdf59e0
>Status: Downloaded newer image for alpine:latest
> ---> b541f2080109
>Successfully built b541f2080109
>```

It reported about successful build and gave the image id back.

The build we did is equal to [docker pull] command. It doesn't modify the source image and even keeps it's name in the local registry.

Let's apply a minimal change to the image.
To do so we will use docker istruction [LABEL] which adds a key-value pair into image metadata.

```Dockerfile
FROM alpine

LABEL revision=2
```

Let's build the modified Dockerfile.

```sh
docker build .
```
>```
>Sending build context to Docker daemon  29.18kB
>Step 1/2 : FROM alpine
> ---> b541f2080109
>Step 2/2 : LABEL revision=2
> ---> Running in a895efe1994b
>Removing intermediate container a895efe1994b
> ---> a4778aec5a4d
>Successfully built a4778aec5a4d
>```

This time we see the new image appeared in the local registry. The image is untagged, it has no tag and has no repository. We also call such images as dangling images. For now it is OK to have the dangling image.

The [LABEL] instruction doesn't add a new layer to an image becuase it doesn't modify a container file system. But it indeed adds a record into an image history that we can see using [lazydocker].

The history of an image can be also retrieved by the [docker history] command.

Let's try the command by giving it ID of our newly created image.
```sh
docker history IMAGE
```

The output the command gave us back it the same that the [lazydocker] shows us.

Now let's see what dockerfile instuction we can use to install the 3rd party component to our image.
On previous learning session we did this via applying a shell command inside a running container. And the command was specific for the operating system of the container.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet
```

Let's build a new image.

```sh
docker build .
```
>```
>Sending build context to Docker daemon   29.7kB
>Step 1/3 : FROM alpine
> ---> b541f2080109
>Step 2/3 : LABEL revision=2
> ---> Using cache
> ---> a4778aec5a4d
>Step 3/3 : RUN apk add figlet
> ---> Running in 356590deb32d
>fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/APKINDEX.tar.gz
>fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/APKINDEX.tar.gz
>(1/1) Installing figlet (2.2.5-r3)
>Executing busybox-1.36.1-r5.trigger
>OK: 8 MiB in 16 packages
>Removing intermediate container 356590deb32d
> ---> 80e427e6a76d
>Successfully built 80e427e6a76d
>```

The command succeeded and gave us a new image ID back.

From what Lazydocker shows us, it looks like no new untagged image was added and the existing untagged image has changed its ID. But we know that a container image is immutable, so probably the old image was deleted and the new one added. But in the image history there is a record corresponding to label addition action and the record has ID equal to the "missing" image ID. Since there is a refference to the image, then the image must exists in the local registry.

Indeed the image does exist and we can verify it by issuing the [docker images] command adding the `--all` flag to it.

```sh
docker images --all
```
>```
>REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
><none>       <none>    80e427e6a76d   4 minutes ago   9.89MB
><none>       <none>    a4778aec5a4d   6 minutes ago   7.34MB
>alpine       latest    b541f2080109   2 days ago      7.34MB
>```

By default the [docker images] hides so called *intermediate* images and shows them only when we ask for it by adding `--all` flag to the command.

We want our new image to run a simple script that will display text isn ASCII art using figlet tool.
Let's create file containing our script in the current working directory.

```sh
echo 'echo $@ | figlet ${FONT:+-f${FONT}}' > banner.sh
```

Then modify our Dockerfile to copy the script from host file system into the image. We will use the [COPY] instruction in its famous canonical form - "copy dot dot".

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

COPY . .
```

We've changed our Dockerfile, so we have to build a new image from it.

```sh
docker build .
```
>```
>Sending build context to Docker daemon  35.33kB
>Step 1/4 : FROM alpine
> ---> b541f2080109
>Step 2/4 : LABEL revision=2
> ---> Using cache
> ---> a4778aec5a4d
>Step 3/4 : RUN apk add figlet
> ---> Using cache
> ---> 80e427e6a76d
>Step 4/4 : COPY . .
> ---> fdb9654e8c31
>Successfully built fdb9654e8c31
>```

The copy instruction we added to our Dockerfile caused creating a new image on top of the previous image that is now became intermediate.

If we look closely into the docker build command output, we can see that it contains four steps each of which corresponds to instructions in our Dockerfile one step per instruction.

We also see that all the three steps that preceding to the copy instruction use cache from the intermediate images. This happens because we didn't change any Dockerfile instruction corresponding to the steps. And this is a purpose to keep intermediate images.

Let's see what will happen if we do change the Dockerfile instruction. We are going to change the label that we added on the second build. Let's make the revision label value equal to the number of istructions present at the moment in the Dockerfile.

```Dockerfile
FROM alpine

LABEL revision=4

RUN apk add figlet

COPY . .
```

Then run build again.

```sh
docker build .
```
>```
>Sending build context to Docker daemon  36.86kB
>Step 1/4 : FROM alpine
> ---> b541f2080109
>Step 2/4 : LABEL revision=4
> ---> Running in 33d91658f5dd
>Removing intermediate container 33d91658f5dd
> ---> 61a1e4c056d0
>Step 3/4 : RUN apk add figlet
> ---> Running in 196bbdccc35e
>fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/APKINDEX.tar.gz
>fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/APKINDEX.tar.gz
>(1/1) Installing figlet (2.2.5-r3)
>Executing busybox-1.36.1-r5.trigger
>OK: 8 MiB in 16 packages
>Removing intermediate container 196bbdccc35e
> ---> 22c2cfd2a70e
>Step 4/4 : COPY . .
> ---> 9e01a9d1712d
>Successfully built 9e01a9d1712d
>```

We see that Docker re-applied all the instructions creating a new intermediate image for each instruction starting from the modified one.

If we list images in our local registry including intermediate images we can see that the number of images corresponds to a number of all instructions in the Dockerfile plus number of instructions that were re-built.

```sh
docker images --all
```
>```
>REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
><none>       <none>    22c2cfd2a70e   About a minute ago   9.89MB
><none>       <none>    9e01a9d1712d   About a minute ago   9.91MB
><none>       <none>    61a1e4c056d0   About a minute ago   7.34MB
><none>       <none>    fdb9654e8c31   About an hour ago    9.91MB
><none>       <none>    80e427e6a76d   2 hours ago          9.89MB
><none>       <none>    a4778aec5a4d   2 hours ago          7.34MB
>alpine       latest    b541f2080109   2 days ago           7.34MB
>```

And according to `lazydocker` now we have two untagged images. We can check it by appliyng the [docker images] command without `--all` flag.

```sh
docker images
```
>```
>REPOSITORY   TAG       IMAGE ID       CREATED             SIZE
><none>       <none>    9e01a9d1712d   13 minutes ago      9.91MB
><none>       <none>    fdb9654e8c31   About an hour ago   9.91MB
>alpine       latest    b541f2080109   2 days ago          7.34MB
>```

So in fact, we now have to branches of the change history with a leaf image for each branch.

You might ask why Docker keeps the old image and all its intermediates. Let's see why by changing back the label value and building again. Any guesses?

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

COPY . .
```

```sh
docker build .
```
>```
>Sending build context to Docker daemon  39.42kB
>Step 1/4 : FROM alpine
> ---> b541f2080109
>Step 2/4 : LABEL revision=2
> ---> Using cache
> ---> a4778aec5a4d
>Step 3/4 : RUN apk add figlet
> ---> Using cache
> ---> 80e427e6a76d
>Step 4/4 : COPY . .
> ---> f9d0b368d545
>Successfully built f9d0b368d545
>```

Docker re-used all the existing intermidiate images and did not create any new image.

The [docker build] command has `--no-cache` flag that asks Docker not to use cached images when building. This option might be used when we want to check how the clean build works. But be aware that in this case Docker creates a new set of intermediate images and the leaf image in the local registry each time you do a new build.

All the intermediate and dangling images can be removed by means of the [docker image prune] command.

```sh
docker image prune --force
```

Let's come back to the RUN instruction that we use in the Dockerfile to install `figlet` tool.
On the previous learning session we used running container in order to execute installation commands.
The Dockerfile RUN instruction also requires a running container and Docker creates or creates and runs an intermediate container for each instruction that requires it. 

But if we use [docker ps] command even with `--all` flag it will show us nothing.
This happens because Docker automatically removes all the intermediate containers.
We can see these containers if we use [docker build] command with `--rm` option set to `false`.

```sh
docker build . --rm=false
```

To clean up from all intermediate images and containers we use docker image prune and docker container prune commands accordingly but remove containers first because they refer images and, thus, the images are not dangling and will not be pruned if we try to remove them first.

```sh
docker container prune --force
```
```sh
docker image prune --force
```

Let's review our Dockerfile [COPY] instruction.
We use it in form of "copy dot dot" but what does it actually mean? What does it copy and where it puts the copy.

We can see what is inside our image filesystem by creating a container from it, run the container and check on its files using standard linux commands. But firstly, let's build our image and give it a name so we can easily refer it in subsequent docker commands.

```sh
docker build . --tag drapel
```

```sh
docker run --rm --interactive --tty drapel
```

```sh
ls
```

We see a bunch of names in the list and among those names there is `banner.sh` which is our script.

So the [COPY] instruction we used copied files into default working directory inside the image. This happens when we use `.` as a second argument of the [COPY] instruction. We will see later how we can change the image default working directory.

The magority of the names we see from the list command output, belong to files and directories inside the container. So to distinguish them let's copy our files into a distinct place in the image file system.
We can do it by setting the path we want our files to be copied into instead of the second `.` in the [COPY] instruction.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

COPY . /var/workspace
```

Let's build an image and run a container from it.

```sh
docker build . --tag drapel
docker run --rm --interactive --tty drapel
```

If we list the current directory with the `ls` command will not see our script there.
Let's list the directory we specified in the [COPY] instruction.

```sh
ls /var/workspace
```

We see that the directory exists, it is not empty, and there is our `banner.sh` file.

So the second parameter of the [COPY] instruction is a destination path inside an image file system. And the [COPY] instruction creates all the directories along the path if they do not exist.

We can see that we copied all the content of our host system current working directory.
So it looks like the first `.` in the [COPY] instruction designates current working directory. But this is not always true.

The `COPY . .` means copy everything from some directory on a host system into some directory in an image file system. But what exactly are those directories?

Regarding the first `.`, it refers to the directory on a host file system that was specified in the [docker build] command as its parameter. Since we also specified `.` there, Docker bonded our host system current working directory to the `.` that we use as a first parameter of a [COPY] instruction. If we pass another directory to the [docker build] comand then the first `.` in a [COPY] instruction will refer this particular directory.

I found several talks on the Internet where people claimed that the first `.` refers a directory where a Dockerfile resides. Indeed, often it is so but not everytime. 

We call a directory that is passed as a parameter of the [docker build] command a `docker context`. And it is not required that a Dockerfile must reside in the docker context. It can be placed anywhere even outside the docker context and its subdirectories. The [docker build] command has `--file` option that specifies a path to a Dockerfile.

Very important thing is that inside a Docker file we cannot refer any file outside a docker context.

But we can easily have multiple different Dockerfiles that share a single docker context and use a different parts of it each.

Let's talk about a default directory for the second `.` a bit later and return to our Dockerfile and the copy instruction.

Frankly speaking, we need to copy only the script file and the rest should not go to the image.
Presumable, we can achieve it by replacing the first `.` in the [COPY] instruction to the name of our script file. But here is a tricky part. When we copy a single file the destination will be treated as a file name, thus, it will copy our `banner.sh` into a file named `workspace`. So to avoid this misbehaviour we have to repeat name of the file in the destination path. Of course, we can choose another name if we like.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

COPY banner.sh /var/workspace/banner.sh
```

It's allowed to use file name patterns like `*.sh`. It will copy all the files that fit to the pattern. In this case we have to add `/` to the end of destination path to explicitly designate it as a directory. Otherwise, build will fail with a proper diagnostic message.

BTW, adding `/` at the end of destination path allows us to avoid file name duplication.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

COPY banner.sh /var/workspace/
```

Despite we replaced the first `.` with a file name, the docker context still has its influence on any source path we use in a [COPY] instruction. All these paths are relative to the docker context.

Regarding the second `.`, it refers to the working directory in an image file system. This working directory by default is a root directory and can be changed by the [WORKDIR] instruction.

Let's rewrite our Dockerfile to copy our script into an image in to the same location as before, but using the [WORKDIR] istruction.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

WORKDIR /var/workspace

COPY banner.sh .
```

In contrast to source paths, a destination paths not always are relative to the [WORKDIR]. If we start a destination path with `/` it will make it an absolute path that doesn't rely on [WORKDIR].

The [WORKDIR] instruction also creates all the directories along the path. There can be as many [WORKDIR] instructions in a Dockerfile as you need, the image will have its default working directory equal to directory set by the last [WORKDIR] instruction.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

WORKDIR /var/workspace

COPY banner.sh .

CMD sh /var/workspace/banner.sh
```

Notice that in the [CMD] instruction we use full path to our script. It's because the istruction doesn't rely on [WORKDIR]. I guess, this is done so because working directory can be changed during a container creation, thus the container instruction can be broken.

Let's build a new image.

```sh
docker buld . --tag drapel
```

Let's run it.

```sh
docker run --rm drapel
```

It looks like it has printed a bunch of empty lines.

According to the script it expects arguments it will print out.
Let's try to pass one word.

```sh
docker run --rm drapel hello
```
>```
>docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "hello": executable file not found in $PATH: unknown.
>ERRO[0001] error waiting for container:
>```

We got the error. Let's see what's wrong.

As you might remember from previous sessions, the [docker run] command uses its arguments as a command to be run instead of default command stored in the image. So we actually asked docker to run `hello` inside the container instead of our script. Indeed it is failed because there is no executable named `hello` in the image.

We need to run our script regardless of the arguments specified in the [docker run] and get those arguments as arguments for our script.

We can do it by using [ENTRYPOINT] instruction. According to the documentation an [ENTRYPOINT] allows us to configure a container that will run as an executable. That is exactly what we need.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

WORKDIR /var/workspace

COPY banner.sh .

ENTRYPOINT sh /var/workspace/banner.sh
```

```sh
docker build . --tag drapel
docker run --rm drapel
docker run --rm drapel hello
```

But again, nothing printed out.

If we look into image history we will notice that in fact the entrypoint is a bit different of what we have specified in our Dockerfile. It has `/bin/sh -c` prepended.

The way we use [ENTRYPOINT] instruction in our Dockerfile is so called `shell form`. Docker prepends [ENTRYPOINT] and [CMD] written in the `shell form` with default shell. For Linux containers it is `/bin/sh -c` for Windows containers it is `cmd /S /C`.

We can avoid this transformation by presenting [ENTRYPOINT] in JSON format.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

WORKDIR /var/workspace

COPY banner.sh .

ENTRYPOINT ["sh", "/var/workspace/banner.sh"]
```

Let's build and run.

```sh
docker build . --tag drapel
docker run --rm drapel hello
```

Now it works as expected.

But if we run it without arguments it prints out empty lines.
Since we have our entrypoint defined, we can define default arguments by using [CMD] instruction. Let's add it also in JSON format.

```Dockerfile
FROM alpine

LABEL revision=2

RUN apk add figlet

WORKDIR /var/workspace

COPY banner.sh .

ENTRYPOINT ["sh", "/var/workspace/banner.sh"]

CMD ["nothing in", "something out"]
```

Let's build and run.

```sh
docker build . --tag drapel
docker run --rm drapel
```

Now instead of empty lines, we see the text we declared using [CMD] instruction.

Let's run our image with giving it something meaningful as an input.

```sh
docker run --rm --env FONT=mini drapel A remarkable achievement is just what a long series of unremarkable tasks look like from far away.
```

## Epilogue

On today's session we have created a complete and working container image using a dockerfile. We have seen how Docker uses intermediate images and containers to efficiently execute our dockerfile instructions. We delved into details of the CMD and ENTRYPOINT instructions.

# Study materials

[Docker images](https://capgemini.udemy.com/course/learn-docker/learn/lecture/7894020#overview)

[Docker layered architecture](https://capgemini.udemy.com/course/learn-docker/learn/lecture/15829082#overview)

[Environment variables](https://capgemini.udemy.com/course/learn-docker/learn/lecture/12240112#overview)

[Command vs entrypoint](https://capgemini.udemy.com/course/learn-docker/learn/lecture/12485580#overview)

[Building images with Dockerfiles](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/16123011#overview)

[CMD]: https://docs.docker.com/engine/reference/builder/#cmd
[COPY]: https://docs.docker.com/engine/reference/builder/#copy
[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[docker history]: https://docs.docker.com/engine/reference/commandline/history/
[Docker Hub]: https://hub.docker.com
[docker image prune]: https://docs.docker.com/engine/reference/commandline/image_prune/
[docker images]: https://docs.docker.com/engine/reference/commandline/images/
[docker ps]: https://docs.docker.com/engine/reference/commandline/ps/
[docker pull]: https://docs.docker.com/engine/reference/commandline/pull/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/
[ENTRYPOINT]: https://docs.docker.com/engine/reference/builder/#entrypoint
[FROM]: https://docs.docker.com/engine/reference/builder/#from
[LABEL]: https://docs.docker.com/engine/reference/builder/#label
[lazydocker]: https://github.com/jesseduffield/lazydocker
[WORKDIR]: https://docs.docker.com/engine/reference/builder/#workdir

---
**[Top](#)**
&emsp;[Course](/README.md)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

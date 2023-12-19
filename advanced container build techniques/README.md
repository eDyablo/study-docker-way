**[Course](../README.md)**
&emsp;[Study materials](#study-materials)
&emsp;[Homework assignment](./homework/README.md)

# Advanced build techmiques

**Use Dockerfile as template and more**

Hello and welcome to the Docker couse and its next learning session devoted to advanced container build techniques.

Today we are going to see how we can use Dockerfile instructions more efficiently. We will review already know dockerfile instructions in more details. We will also get acquainted with the technique that allows to re-use docker images and avoid code duplication.

## Multiline instructions

Let's start with a simple dockerfile.

```sh
cat multiline/Dockerfile
```
```Dockerfile
FROM alpine

RUN apk update
RUN apk add figlet
RUN apk add cowsay --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
```

The dockerfile has several [RUN] instructions executing `apk` related commands.
We know that an image consists of multiple images layered on top of each other, and each Dockerfile instruction creates additional image in the image stack.

In the example we use [RUN] instructions to install two different system packages, `figlet` and `cowsay`.
Actually the `apk` allows to add multiple packages in one command, but in our case the `cowsay` resides in packages repository different from one the `figlet` resides in. So we have to use two different `apk add` commands.

Let's build an image from the dockerfile.

```sh
docker build multiline --tag acbt-multiline
```

We can see the image stack by looking into its history using the [docker history] command.

```sh
docker history acbt-multiline
```
>```
>IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
>e0559709372e   12 seconds ago   /bin/sh -c apk add cowsay --repository=https…   38.2MB    
>3f127c78a23b   24 seconds ago   /bin/sh -c apk add figlet                       675kB     
>b2044589994e   29 seconds ago   /bin/sh -c apk update                           2.18MB    
>f8c20f8bbcb6   10 days ago      /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
><missing>      10 days ago      /bin/sh -c #(nop) ADD file:1f4eb46669b5b6275…   7.38MB
>```

We see images corresponding to the instructions stack up from bottom to top starting from base image's stack.

We can also review the image layers by means of the [docker inspect] command.

```sh
docker inspect acbt-multiline --format '{{ join .RootFS.Layers "\n" }}'
```
>```
>sha256:5af4f8f59b764c64c6def53f52ada809fe38d528441d08d01c206dfb3fc3b691
>sha256:cd075f8db3fe9bc265790fd241cbd86a4f4e041a06c749a2d1b258999ba805f2
>sha256:780abe6b3ee24c6834f3e4e8f12281f67bb35320c5be118e3797b35ec00470f8
>sha256:38db2a9912195e5cfc0ef1265b54a030e30dd9d5dd8cbf1eb905da87392fbb8f
>```

Here we have one layer from base image and three layers corresponding to `apk` related [RUN] instructions. The instructions have added layers because `apk` related commands modify filesystem.

Actually we can control the number of images in the image stack and so the number of layers by combining several [RUN] instructions into one. Let's see how we can do it.

```sh
cat multiline/Dockerfile.new
```
```Dockerfile
FROM alpine

RUN \
  apk update \
  && apk add figlet \
  && apk add cowsay \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
```

Here we use Linux ability to run multiple commands written in one line. We can read it as "update apk and add filget and add cowsay".
I said that the commands are written in one line but you see multiple lines here. Of course we can put it all in in one line, but in sake of readability we use backward slashes to visually split one line into multiple lines.
When we use Docker on Windows and build an images using cmd shell we have to use its specific ways for running commands using one line and for visual splitting a line.

Let's build an image from the new dockerfile.

```sh
docker build multiline --file multiline/Dockerfile.new --tag acbt-multiline-new
```

Let's review image history.

```sh
docker history acbt-multiline-new
```
>```
>IMAGE          CREATED         CREATED BY                                      SIZE      COMMENT
>3d00c73307fe   7 seconds ago   /bin/sh -c apk update   && apk add figlet   …   41MB      
>f8c20f8bbcb6   10 days ago     /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
><missing>      10 days ago     /bin/sh -c #(nop) ADD file:1f4eb46669b5b6275…   7.38MB
>```

Now we see three images in the stack instead of five. Let's check image layers.

```sh
docker inspect acbt-multiline-new --format '{{ join .RootFS.Layers "\n" }}'
```
>```
>sha256:5af4f8f59b764c64c6def53f52ada809fe38d528441d08d01c206dfb3fc3b691
>sha256:6b9c51a4b607a5fdec6de350c0a404976f3670d0f113b880117903ffcd842869
>```

Here are only two layers.

It doesn't mean that we have to put all [RUN] instructions into one. In case we do this, then instead of multiple small images and layers we would have one big layer. This would increase the image re-build time because we would have to re-build the whole layer each time we modify any part of this one [RUN] isntruction.
We have to use a common sense and keep balance between two extremes.

In reality we use multiple [RUN] instruction each of which consists of multiple commands that are closely related to each other.

Let's review the following Dockerfile.

```sh
cat multiline/Dockerfile.real
```
```Dockerfile
FROM alpine

# Install system level components
RUN \ 
  apk add --update --no-cache \
    binutils \
    py3-pip \
  && pip install --upgrade --break-system-packages \
    pip

# Install python packages
RUN \
  pip install --upgrade --break-system-packages \
    click \
    pyinstaller

WORKDIR /var/workspace
```

Here we have two logical blocks. Each block has a comment describing in short words its purpose.

It is recommended to place instructions that less likely to be changed closer to beginning of Dockerfile and instructions that highly likely to be modified closer to end of Dockerfile. This way we optimize amount of layers to be rebuilt and thus optimize image building time.

## COPY

Not only [RUN] instruction allows to combine multiple instructions into one. Let's review [COPY] instuction.

```sh
cat copy/Dockerfile
```
```Dockerfile
FROM busybox

COPY file-a workspace/
COPY file-b workspace/

COPY dir-a workspace/dir-a
COPY dir-b workspace/dir-b
```

In the docker file we copy several files into `workspace/files` directory and then copy several directories into `workspace/dirs` directory.

Let's build an image.
```sh
docker build copy --tag acbt-copy
```

And let's look into the `workspace` directory by running container and executing the `tree` command that visually displays a directory structure.

```sh
docker run --rm acbt-copy tree workspace
```
>```
>workspace
>├── dir-a
>│   ├── a-1
>│   └── a-2
>├── dir-b
>│   └── b-1
>├── file-a
>└── file-b
>```

We see that under the `workspace` directory we have two files and two directories with their files correspondingly.

In the [COPY] instruction we can use multiple sources.

```sh
cat copy/Dockerfile.new
```
```Dockerfile
FROM busybox

COPY file-a file-b workspace/

COPY dir-a dir-b workspace/
```

Now we have less [COPY] instructions and each instruction don't use a single source and destination pair of paths. Instead they list source files and source directories and has a destination as a last item in the list.
So the [COPY] instruction allows us to specify in one instruction multiple sources that will be copied into single destination.

Let's see the result.
We have to build a new image.

```sh
docker build copy --file copy/Dockerfile.new --tag acbt-copy-new
```

Let's see the new directory structure.

```sh
docker run --rm acbt-copy-new tree workspace
```
>```
>workspace
>├── a-1
>├── a-2
>├── b-1
>├── file-a
>└── file-b
>```

We got a bit different result in compare with the previous example. The content of `dir-a` and `dir-b` directories were put into destination directory without creating corresponding subdirectories. So be aware of this behaviour when use such form of the [COPY] command.

The COPY instruction also support file patterns the same way we can use them in Linux or Windows command line to refer multiple files with names fit to a pattern.

## ADD

Docker is providing [ADD] instruction that is equal to [COPY] instruction except it additionally can copy from remote URL and from remote git repository.

```sh
cat add/Dockerfile
```
```Dockerfile
FROM scratch

ADD https://www.google.com/index.html google.html
```

Let's build an image.

```sh
docker build add --tag acbt-add
```

Let's run an image that will print out the `google.html` file it should get from the URL.

```sh
docker run --rm acbt-add cat google.html
```

## ARG

When we create or run a container from an image we can pass to it a set of values using `--env` option. These values are accessible by the container's executables as system environment variables. It allows us to change the container behavior without re-building the container image. Let's recall how it can be done.

```sh
cat arg/Dockerfile
```
```Dockerfile
FROM alpine

RUN apk add --update --no-cache figlet

ENV FONT=big

ENTRYPOINT [ "sh", "-c", "echo $0 $@ | figlet -f$FONT" ]
```

We have Dockerfile that using [ENV] instruction declares `FONT` environment variable with a default value. The variable then used in [ENTRYPOINT] script.
Using this setup we build an image only once and specify a new value each time we create a new container from the image.

```sh
docker build arg --tag acbt-arg
```

Let's look into the image history.

```sh
docker history acbt-arg
```
>```
>IMAGE          CREATED         CREATED BY                                      SIZE      COMMENT
>7f3d350755b0   5 seconds ago   /bin/sh -c #(nop)  ENTRYPOINT ["sh" "-c" "ec…   0B        
>6dab1ca58cb5   6 seconds ago   /bin/sh -c #(nop)  ENV FONT=big                 0B        
>c92d6a7324f4   6 seconds ago   /bin/sh -c apk add --update --no-cache figlet   675kB     
>f8c20f8bbcb6   10 days ago     /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
><missing>      10 days ago     /bin/sh -c #(nop) ADD file:1f4eb46669b5b6275…   7.38MB
>```

We see the enviornment variable has default value equal to `big`.
What if we need to change the default value without modifying the Dockerfile, so we can use the same Dockerfile to build images with different default values for the environment variable?

Let's see how we can achive this.

```sh
cat arg/Dockerfile.new
```
```Dockerfile
FROM alpine

RUN apk add --update --no-cache figlet

ARG DEFAULT_FONT=big

ENV FONT=${DEFAULT_FONT}

ENTRYPOINT [ "sh", "-c", "echo $0 $@ | figlet -f$FONT" ]
```

We see a new instruction [ARG]. Using the instruction we define named variable and give it a value. Then we refer the `DEFAULT_FONT` variable and pass its value to the `FONT` environment variable.

Why do we need another variable to simply pass its value to the existing variable?

The thing is that the [ARG] instruction defines a variable that we can pass at build-time, which we can not do with [ENV] instruction.

Let's build a new image.

```sh
docker build arg --file arg/Dockerfile.new --tag acbt-arg-new --build-arg DEFAULT_FONT=script
```

To pass values for build-time variables we use `--build-arg` option of the [docker build] command.

Let's see its history.

```sh
docker history acbt-arg-new
```
>```
>IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
>33d0255d86e0   4 seconds ago    /bin/sh -c #(nop)  ENTRYPOINT ["sh" "-c" "ec…   0B        
>8ae4dc39124e   5 seconds ago    /bin/sh -c #(nop)  ENV FONT=script              0B        
>7eee539f9402   5 seconds ago    /bin/sh -c #(nop)  ARG DEFAULT_FONT=big         0B        
>c92d6a7324f4   59 seconds ago   /bin/sh -c apk add --update --no-cache figlet   675kB     
>f8c20f8bbcb6   10 days ago      /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
><missing>      10 days ago      /bin/sh -c #(nop) ADD file:1f4eb46669b5b6275…   7.38MB
>```

Now we see that the `FONT` environment variable has its default value equal to the value we passed as a build argument.

An [ARG] variable definition comes into effect from the line on which it is defined in the Dockerfile.
It is recommended to place [ARG] declaration closer to its first usage in Dockerfile. Because as any other Dockerfile instruction, the [ARG] instruction introduces a new layer in image stack all the subsequent layers depend on. For instance, if we place all ARGs at the beginning, we will end up rebuilding the whole image everytime a value of any argument has changed.

Be aware that environment variables defined using the [ENV] instruction always override an [ARG] instruction of the same name.

![Docker ENV and ARG](https://vsupalov.com/images/docker-env-vars/docker_environment_build_args.png)

## LABEL

The [LABEL] instruction adds metadata to an image. A [LABEL] is a key-value pair.

We used the instuction on one of previous sessions for demostration purpose. Let's see more realistic example.

```sh
cat label/Dockerfile
```
```Dockerfile
FROM busybox

ARG BUILD_DATE
ARG ORGANISATION=Capgemini
ARG VCS_REF
ARG VCS_URL

LABEL \
	org.opencontainers.image.authors=eduard.a.yablonskyi@capgemini.com \
	org.opencontainers.image.created=${BUILD_DATE} \
	org.opencontainers.image.revision=${VCS_REF} \
	org.opencontainers.image.source=${VCS_URL} \
	org.opencontainers.image.vendor=${ORGANISATION}
```

Here we have a set of labels that add useful metadata such as date when the image has been created, reference to its source code and revision, name of the vendor organization and authors.

Community puts an effort to standardize labels for container images. The set of labels above is a part of `Open Container Initiative`.

The labels in our example use [ARG] values. If we run [docker build] command without providing arguments for them, there will be no error and the values will be empty. And the labels being added will have only keys with no values.

```sh
docker build label --tag acbt-label --build-arg ORGANISATION=Lohika --build-arg VCS_REF=$(git rev-parse HEAD)
```

Let's list all the image labels by using the [docker inspect] command.

```sh
docker inspect acbt-label --format '{{ json .Config.Labels }}' | jq
```

We see the labels we passed arguments for have appropriate values.

## ONBUILD

What if we need all our images contains a particular set of labels that gets populated by values from our CI pipeline?
It would be inefficient, error-prone and difficult to update, if we ask developers to repeat the same Dockerfile code in each image they develop.

We can create a reusable dockerfile definition. Let's see how we can do it.

```sh
cat onbuild/Dockerfile.template
```
```Dockerfile
FROM scratch

ONBUILD ARG \
  BUILD_DATE \
  ORGANISATION=Capgemini \
  VCS_REF \
  VCS_URL

ONBUILD LABEL \
	org.opencontainers.image.created=${BUILD_DATE} \
	org.opencontainers.image.revision=${VCS_REF} \
	org.opencontainers.image.source=${VCS_URL} \
	org.opencontainers.image.vendor=${ORGANISATION}
```

The docker file has `scratch` as its base, meaning it start as an empty image.
Then there are two instructions, [ARG] and [LABEL]. But each one has [ONBUILD] prefix.

Let's build an image.

```sh
docker build onbuild --file onbuild/Dockerfile.template --tag acbt-onbuild-template
```

Now we have the image we can use as a base for other images.

```sh
cat onbuild/Dockerfile
```
```Dockerfile
FROM acbt-onbuild-template
```

The Dockerfile has only one instruction which is [FROM]. Let's build an image from the file.

```sh
docker build onbuild --tag acbt-onbuild
```

If we look into the image history...

```sh
docker history acbt-onbuild
```

We would see it has two additional layers corresponding to [ARG] and [LABEL] from the base image. This time they have no [ONBUILD] prefix. The Docker automatically applied the instructions.

This technique is useful if we are building an image which will be used as a base to build other images.

An instruction following [ONBUILD] is called a `trigger`, because it's not executed immediately but get triggered when the image is used as the base for another build.

Any build instruction except [FROM] can be registered as a trigger.

For example, we need a reusable C++ application builder, which requires application source code to be added in a particular directory, and then it runs the compiler to assemble an executable.
We can not just use [ADD] and [RUN] instructions in the builder image Dockerfile, because we don't have the application source code, and it will be different for each application build.

Let's write a Dockerfile to build the image.

```sh
cat onbuild/builder/Dockerfile.cpp-builder
```
```Dockerfile
FROM alpine

RUN apk add --no-cache g++

ONBUILD ADD src /src

ONBUILD RUN mkdir /out

ONBUILD RUN g++ -static -o /out/app /src/*.cpp
```

In the image we install all required system level components. In our case they are C++ tools used to assemble executables for C++ source code.
Then we have a set of [ONBUILD] instructions that will be triggered in context of another Dockerfile.
It copies `src` directory into image filesystem, makes the `out` directory and assembles executable named `app` in the `out` directory from all `cpp` files in `src` directory.

We can build our c++ builder image.
```sh
docker build onbuild/builder --file onbuild/builder/Dockerfile.cpp-builder --tag cpp-builder
```

Now we can write Dockerfile for image that will have executable built from sources using the builder image we have just created.

```sh
cat onbuild/builder/Dockerfile
```
```Dockerfile
FROM cpp-builder AS builder

FROM scratch

COPY --from=builder /out/app /bin/app

ENTRYPOINT [ "/bin/app" ]
```

We use the `cpp-builder` image as `builder` and immediately after this we start a new image from `scratch` and copy file from `builder` image into our final image. We can do it because Docker will trigger all [ONBUILD] instructions on the first step when we use the [FROM] instuction. After the step completed our image will have executable in its `out` directory. So we can start a fresh image from `scratch` and copy the executable. Thus, the final image will contain only the executable with no tools that we used in builder image and no intermediate files.

Let's build an image.

```sh
docker build onbuild/builder --tag hello-cpp
```

In the messages the build command reports us back we see that build triggers were executed in the first step.

We can run a container to check the image we have built.

```sh
docker run --rm hello-cpp
```

BTW, we can use this Dockerfile to create images for another applications by switching Docker Context and specifying different image name in the [docker build] command. All that we need is to have our C++ files in `src` directory under the Docker Context.

# Epilogue

Today we saw how to compose image layers using multi-line run instructions. We used new instructions such as [ADD] and [ARG]. We used [LABEL] instruction to provide meaningfull metadata for an image. We reviewed in details the new syntax of [COPY] instruction and how it could be used to copy multiple files using one instruction. And we have learned about [ONBUILD] instruction by means of which we can build re-usable images we can efficiently build other images from.

# References

[Docker ARG vs ENV](https://vsupalov.com/docker-arg-vs-env/)
[Label Schema](http://label-schema.org/rc1/)
[Open Containers Image Annotations](https://github.com/opencontainers/image-spec/blob/main/annotations.md)

[ADD]: https://docs.docker.com/engine/reference/builder/#add
[ARG]: https://docs.docker.com/engine/reference/builder/#arg
[COPY]: https://docs.docker.com/engine/reference/builder/#copy
[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[docker history]: https://docs.docker.com/engine/reference/commandline/history/
[docker inspect]: https://docs.docker.com/engine/reference/commandline/inspect/
[ENTRYPOINT]: https://docs.docker.com/engine/reference/builder/#entrypoint
[ENV]: https://docs.docker.com/engine/reference/builder/#env
[FROM]: https://docs.docker.com/engine/reference/builder/#from
[LABEL]: https://docs.docker.com/engine/reference/builder/#label
[ONBUILD]: https://docs.docker.com/engine/reference/builder/#onbuild
[RUN]: https://docs.docker.com/engine/reference/builder/#run

---
**[Top](#)**
&emsp;[Course](/README.md)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

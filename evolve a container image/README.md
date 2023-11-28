**[Course](../README.md)**
&emsp;[Study materials](#study-materials)
&emsp;[Homework assignment](./homework/README.md)

# Evolve a container image

**Become able to extend existing container image without writing Dockerfile**

Hello everyone and welcome to the Docker course and its next learnig session.

Today we are going to create a new image from an existing one. We will get publicly available image, modify its content by installing a 3rd party software, copy our script into it, set default environment variable values and publish the image.

On the previous session we also used an existing image to create a container and modified the container so it does a required task. But we had to apply the same modifications each time we created a new container.

We need a way to run a container without repeating the same actions. Docker allows us to achieve this by creating an image from a container. Today we'll learn how to do this.

## Prepare it

For demonstration we'll create a container image that can be used to display the current time in a fancy way.

We will use the tool named `figlet` that displays text in [ASCII art].

![figlet ASCII art example](https://cdn.ourcodeworld.com/public-media/articles/figlet-ascii-art-ubuntu-604913512fe73.png)

The script that our container will run, prints out current time every second. Let's create a file containing the script.

```sh
echo 'while true; do
  clear
  date "+${FORMAT:-%T}" | figlet ${FONT:+-f$FONT}
  sleep 1
done
' > clock.sh
```

Container images are immutable by their nature so we can't modify them directly. In order to make a change we have to create a new container from the image of our interest, make changes to the container, and then create a new image from the modified container.

We will use `alpine` image as a base for our future image.
The modification we are going to make requires the running container. And we need to run the container in interactive mode meaning we attach our terminal's standard input and output to the container. We also need to give the container a name in order to refer it in other commands. So, let's run the container via [docker run] command.

```sh
docker run --rm --name ceas --interactive alpine
```
>```
>Unable to find image 'alpine:latest' locally
>latest: Pulling from library/alpine
>96526aa774ef: Pull complete
>Digest: sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978
>Status: Downloaded newer image for alpine:latest
>```

Now we are inside the container running linux shell with our terminal connected to the shell session.

We added `--rm` flag to the command to make the container autodisposable, meaning it will be removed once it completed its run.
Since we are in interactive mode the container will keep alive until we exit from the terminal session.

The `figlet` is not a part of the `alpine` image we created our container from, so we have to install it first. The installation should be done according to the container's operating system. Since it is `Alpine Linux`, we have to use `Alpine Package Keep` or `apk`.

Let's run the proper command inside the running container.

```sh
apk add figlet
```
>```
>fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/APKINDEX.tar.gz
>fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/APKINDEX.tar.gz
>(1/1) Installing figlet (2.2.5-r3)
>Executing busybox-1.36.1-r2.trigger
>OK: 8 MiB in 16 packages
>```

The `apk` reported back that the installation was successful.

Of course, this action has modified the container file system by adding files to it. We can review the file system changes by means of [docker diff] command.

Since the terminal is occupied by the running container's linux session, to be able to apply docker commands we have to use another terminal.

```sh
docker diff ceas
```

We see a bunch of modifications related to the installation we did.

The change we made affects only the running container but our aim is to modify an image.
We should use the [docker commit] command that creates a new image from a container's changes.

```sh
docker commit --message 'add figlet' ceas zegar
```

For the command we specified message describing the change, then we referred container, then we set our new image name.

Let's list images currently present in our docker system.

```sh
docker image ls
```
>```
>REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
>zegar        latest    182db053c85f   About a minute ago   9.89MB
>alpine       latest    8ca4688f4f35   8 weeks ago          7.34MB
>```

As we can see the new image with bigger size appeared in the list.

We can get more detailed information about an image using the [docker image inspect] command.

```sh
docker image inspect zegar
```

The output has a lot of information regarding different aspects of the image.
If we need a particular part of it we can use `--format` option. For instance, let's see information related to the image file system.

But firstly, lets's talk about very important aspect, about image layers.

A container image is composed of multiple layers stacked on top of each other. Each layer represents a specific modification to the file system, such as adding a new file or modifying an existing one. Once a layer is created, it becomes immutable, meaning it can't be changed.

So, an image is immutable because it is composed of immutable layers. In order to make a change we have to create a new layer on top of existing layers and store them as a new image.

Let's look into our newly created image layers.

```sh
docker image inspect zegar --format '{{ .RootFS.Layers }}'
```
>```
>[sha256:cc2447e1835a40530975ab80bb1f872fbab0f2a0faecf2ab16fbbb89b3589438 sha256:e1abb28554e528e0c3af38946e32a9985c884600829dd37a3adabfd600692ff0]
>```

We can output them in json format.

```sh
docker image inspect zegar --format '{{ json .RootFS.Layers }}'
```
>```
>["sha256:cc2447e1835a40530975ab80bb1f872fbab0f2a0faecf2ab16fbbb89b3589438","sha256:e1abb28554e528e0c3af38946e32a9985c884600829dd37a3adabfd600692ff0"]
>```

For a better view we will present the list of layers by one item in a line.

```sh
docker image inspect zegar --format '{{ join .RootFS.Layers "\n" }}'
```
>```
>sha256:cc2447e1835a40530975ab80bb1f872fbab0f2a0faecf2ab16fbbb89b3589438
>sha256:e1abb28554e528e0c3af38946e32a9985c884600829dd37a3adabfd600692ff0
>```

As you may see, we have two layers here. The first one is the original image layer, which is `alpine` image in our case. To make sure, we can run the same [docker image inspect] command against the `alpine` image, but let's do it later.

Each layer is identified by a hash calculated from the layer own contents as well as the hashes of all layers before it. So each layer hash value depends on the layer contents and on hash value of the layer below in the layers stack. An image layer ID is a kind of chained ID.

We have done with our first modification. So we can exit from the container linux session.

```sh
exit
```

Now we can run a new container from the image we have just created. Let's try it.

```sh
docker run --rm --name ceas --interactive zegar
```

This time we also use interactive mode.

To make sure that we have `figlet` tool properly installed we can try to use the tool.

```sh
echo Hello! | figlet
```
>```
>  _   _      _ _       _
>| | | | ___| | | ___ | |
>| |_| |/ _ \ | |/ _ \| |
>|  _  |  __/ | | (_) |_|
>|_| |_|\___|_|_|\___/(_)
>```

Note, that once we created and run the container we didn't install figlet because it is already there. This is exactly what we are trying to achieve.

We have a required software in place, so we can continue making other modifications to our image.
And next we need to copy the prepared script into the image.

And again to modify the image we have to modify a container and create a new image from it.
We already have the container created so let's use the [docker cp] command to copy the script.

```sh
docker cp clock.sh ceas:/clock.sh
```

This action also has made changes to the container file system those we can see via [docker diff] command.

```sh
docker diff ceas
```
>```
>A /clock.sh
>C /lib
>C /lib/apk
>C /lib/apk/db
>C /lib/apk/db/scripts.tar
>C /lib/apk/db/triggers
>C /lib/apk/db/installed
>C /etc
>C /etc/apk
>C /etc/apk/world
>```

And again we need to use [docker commit] command to store our modifications in a new image.

```sh
docker commit --message 'copy script' ceas zegar
```

The command has reported back the new image id.
Despite we specified the image name we used previously we got a new image. The old image has been wiped out.

Let's list the image layers.

```sh
docker image inspect zegar --format '{{ join .RootFS.Layers "\n" }}'
```
>```
>sha256:cc2447e1835a40530975ab80bb1f872fbab0f2a0faecf2ab16fbbb89b3589438
>sha256:e1abb28554e528e0c3af38946e32a9985c884600829dd37a3adabfd600692ff0
>sha256:2a8a47dd83ec37bf39c1935ad3863ce0d7a0cefacf9bc6446b5084156c469c9a
>```

Now the image consists of three layers

We have done with the second modification and can exit the container linux session.

```sh
exit
```

Let's compare layers of our new image and the original `alpine` image.

```sh
docker image inspect alpine --format '{{ join .RootFS.Layers "\n" }}'
docker image inspect zegar --format '{{ join .RootFS.Layers "\n" }}'
```
>```
>sha256:cc2447e1835a40530975ab80bb1f872fbab0f2a0faecf2ab16fbbb89b3589438
>sha256:cc2447e1835a40530975ab80bb1f872fbab0f2a0faecf2ab16fbbb89b3589438
>sha256:e1abb28554e528e0c3af38946e32a9985c884600829dd37a3adabfd600692ff0
>sha256:2a8a47dd83ec37bf39c1935ad3863ce0d7a0cefacf9bc6446b5084156c469c9a
>```

As we see, the first layer of the new image is the same as the single layer of the original image. Docker does not duplicate layers. In our case both images share a single layer which saves a disk space.

## Command it

At this point, our new image has the required 3rd party software and our script in place, so we can try to run a container from it.

```sh
docker run --rm --name ceas zegar
```

It seems nothing happened. This is because the default command for the original `alpine` image starts linux shell session, and since we didn't attach our terminal to it, the session started and immediately finished.

We need to change the behaviour to start our script instead.

Let's run a new container using the same [docker run] command but this time specify the command we need the image has by default.

```sh
docker run --rm --name ceas zegar sh /clock.sh
```
>```
>  _ ____     ___   __    ____   ___
>/ |___ \ _ / _ \ / /_ _| ___| ( _ )
>| | __) (_) | | | '_ (_)___ \ / _ \
>| |/ __/ _| |_| | (_) | ___) | (_) |
>|_|_____(_)\___/ \___(_)____/ \___/
>```

We see that it does what we expected. So we can commit the change into an image.

You might object and say that we made no change. But in contrast with the previous run the running container this time has a command different from the default one defined in the source image. And from the earlier learning session we know that the command together with its arguments is a property of a container.

So let's commit the change into a new image.

```sh
docker commit --message 'set command' ceas zegar
```

We can stop the running container.

```sh
docker exec ceas kill -SIGINT 1
```

Let's check if there is any change to the image file system.

```sh
docker image inspect zegar --format '{{ join .RootFS.Layers "\n" }}'
```

No new layers have been created, meaning no changes to the file system were done.

Using the [docker image inspect] command we can make sure that our image has proper command.

```sh
docker image inspect zegar --format '{{ .Config.Cmd }}'
```
>```
>[sh /clock.sh]
>```

The command stored in the image is exaclty what we commited.

So now let's run a container from the image again without specifiyng a command.

```sh
docker run --rm --name ceas zegar
```

And now it works as expected and we can stop the container.

```sh
docker exec ceas kill -SIGINT 1
```

## Tweak it

So, currently we have created a container image that allows us to run a container that does what we planned it to do.

The image allows to specify a time format via environment variable which value can be set in a [docker run] command.

```sh
docker run --rm --name ceas --env FORMAT='%D %T' zegar
```
>```
>  _ _    ______   __     ______  _____   _ ____    _ _____  _____ ___
>/ / |  / /___ \ / /_   / /___ \|___ /  / |___ \ _/ |___ /_|___ // _ \
>| | | / /  __) | '_ \ / /  __) | |_ \  | | __) (_) | |_ (_) |_ \ (_) |
>| | |/ /  / __/| (_) / /  / __/ ___) | | |/ __/ _| |___) | ___) \__, |
>|_|_/_/  |_____|\___/_/  |_____|____/  |_|_____(_)_|____(_)____/  /_/
>```

We can also set a font being used by `figlet` tool. It can be done by setting the `FONT` environment variable.

Let's stop the running container and create a new one with different font value.
```sh

docker exec ceas kill -SIGINT 1 && docker wait ceas
```
```sh
docker run --rm --name ceas --env FORMAT='%D %T' --env FONT=script zegar
```

The new container is running and its output looks different.

We can stop the container.

```sh
docker exec ceas kill -SIGINT 1
```

What if we need to change the default font the image uses?

We can create a new container with the `FONT` environment value set in the [docker run] command and then we can commit the change to a new image using the running container. But let's see how the same can be achived another way.

Either approach we use, we have to have a container because as we already know an image is immutable. But this time we don't need a running container because the change we are going to apply doesn't require it. So let's create a container.

```sh
docker create --name ceas zegar
docker ps -a
```

Then we can use known [docker commit] command but this time we add `--change` option to it.

```sh
docker commit --message 'set font env' --change 'ENV FONT=script' ceas zegar
```

The `--change` must be followed by an expression that is a special instruction that docker understands. In our case it is `ENV` instuction which adds specified environment variable and its value to the container.

We have commited the change, so we can remove the created container.

```sh
docker rm ceas
```

And we can make sure that the change has been stored in the image by using the [docker image inspect] command.

```sh
docker image inspect zegar --format '{{ join .Config.Env "\n" }}'
```
>```
>PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
>FONT=script
>```

Let's check our new image by running it.

```sh
docker run --rm --name ceas zegar
```
>```
>  ,  __       ___   ___
>/| /   o|  |/   \o/   \|  |
>  || __  |__|_ __/   __/|__|_
>  ||/  \    |    \     \   |
>  | \__/o   |\___/o\___/   |
>```

Everything works as expected so we can stop the container.

```sh
docker exec ceas kill -SIGINT 1
```

## Keep it

Se we've done with all required modifications and finally we have the image we wanted.

The image resides in our local registry and it can be accidentally deleted or overwritten. We may also intentionally clean up entire docker system on our machine. Thus, we will lost the image and will have to do all the modifications again.

Fortunately, Docker allows us to save an image in a file and restore it from the file that we can put in a safe place.

To store an image into a `tape archive` or so called `tar` file we use [docker save] command.

```sh
docker save --output zegar.tar zegar
```

If we omit the `--output` option the command will send the tape archive contents into standard output.

Let's remove the image from our local registry.

```sh
docker rmi zegar
docker image list
```

Then restore the image from the archive by meas of [docker load] command.

```sh
docker load --input zegar.tar
docker image list
```

Using the [docker save] command we can store not only a single image we can backup and restore a set of images using a single [tar file].

Technically we can stream out whole local image registry into a file.

## Ship it

Using the tar file obtained by [docker save] command we can copy images from our local image registry to a local image registry running on another machine.

It might be enough for some practical use cases. But to share container images to a much broader audience in more manageable way we should use online registries.
One of such registries is [Docker Hub].

We know that we can pull publicly accessible images from the [Docker Hub] without registration. But for storing images there we have to have an account.

The signing up procedure is simple and once we have created an account we have to login using it.

```sh
docker login --username addword
```

Let's try to publish our image by using the [docker push] command.

```sh
docker push zegar
```
>```
>Using default tag: latest
>The push refers to repository [docker.io/library/zegar]
>2a8a47dd83ec: Preparing
>e1abb28554e5: Preparing
>cc2447e1835a: Preparing
>denied: requested access to the resource is denied
>```

It fails because Docker doesn't aware that we are trying to push the image into our repository on Docker Hub registry. We have to explicitly define our intention.
The proper command should look like the following.

```sh
docker push addword/zegar
```
>```
>Using default tag: latest
>The push refers to repository [docker.io/addword/zegar]
>An image does not exist locally with the tag: addword/zegar
>```

But it failed again. And now it complains about non-existent image, which is true because we don't have an image with the specified name.

The thing is that the destination repository must be a part of the image name.
We can achieve it by using [docker tag] command.

```sh
docker tag zegar addword/zegar
```

Let's look how the command affected our local registry.

```sh
docker image ls
```
>```
>REPOSITORY      TAG       IMAGE ID       CREATED             SIZE
>zegar           latest    063f3d1765dc   About an hour ago   9.92MB
>addword/zegar   latest    063f3d1765dc   About an hour ago   9.92MB
>alpine          latest    8ca4688f4f35   8 weeks ago         7.34MB
>```

Looks like the command has created additional image. But the new record in the list and the original one are referring the same image ID, meaning that in fact no new image was created and this is just a reference.

If we delete one of the records that share the same image by using [docker rmi] command, it won't delete the image.

```sh
docker rmi zegar
```
>```
>Untagged: zegar:latest
>```

The command informed us that it has untagged the image, meaning it removed the specified name from the local registry.

Let's try the [docker push] command again.

```sh
docker push addword/zegar
```
>```
>Using default tag: latest
>The push refers to repository [docker.io/addword/zegar]
>2a8a47dd83ec: Pushed
>e1abb28554e5: Pushed
>cc2447e1835a: Pushed
>latest: digest: sha256:a65aa695da96c8a77c1281ae5b9453f1a938ded0b5d71d037a3a2abf7b131f78 size: 947
>```

It's succeeded.

## Use it

Since we have published our image we can remove both records from our local registry.

```sh
docker rmi zegar addword/zegar
```

Let's list images again.

```sh
docker image ls
```
>```
>REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
>alpine       latest    8ca4688f4f35   8 weeks ago   7.34MB
>```

For a clean experiment we will log out from [Docker Hub] registry using the [docker logout] command.

```sh
docker logout
```

Now we can try to run a container using the image resides in the remote registry.

```sh
docker run --rm --name ceas addword/zegar
```

Our docker system has pulled the image, created a container from it and run the container.

```sh
docker exec ceas kill -SIGINT 1
```

## Epilogue

On today's session we took an existing image, we applied modifications to the image file system like adding software and copying a file. We modified the image environment values and its starting command. Then we published the ready image by pushing it into Docker Hub.

# Study materials

[Basic Docker commands](https://capgemini.udemy.com/course/learn-docker/learn/lecture/7894010#overview)

[Docker basic and common commands](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15811284#overview)

[Managing container images](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15836320#overview)

# References
[What Are Docker Image Layers and How Do They Work?](https://kodekloud.com/blog/docker-image-layers/)

[How We Made our Docker Builds Three Times Faster](https://www.ginkgobioworks.com/2020/05/18/optimizing-your-dockerfile/)

[CLI tools you won't be able to live without](https://dev.to/lissy93/cli-tools-you-cant-live-without-57f6)

[ascii art]: https://en.wikipedia.org/wiki/ASCII_art
[docker commit]: https://docs.docker.com/engine/reference/commandline/commit/
[docker cp]: https://docs.docker.com/engine/reference/commandline/cp/
[docker diff]: https://docs.docker.com/engine/reference/commandline/diff/
[docker hub]: https://hub.docker.com/
[docker image inspect]: https://docs.docker.com/engine/reference/commandline/image_inspect/
[docker load]: https://docs.docker.com/engine/reference/commandline/load/
[docker logout]: https://docs.docker.com/engine/reference/commandline/logout/
[docker push]: https://docs.docker.com/engine/reference/commandline/push/
[docker push]: https://docs.docker.com/engine/reference/commandline/tag/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/
[docker save]: https://docs.docker.com/engine/reference/commandline/save/
[tar file]: https://en.wikipedia.org/wiki/Tar_(computing)

---
**[Top](#)**
&emsp;[Course](/README.md)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

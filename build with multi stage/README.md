**[Course](../README.md)**
&emsp;[Study materials](#study-materials)
&emsp;[Homework assignment](./homework/README.md)

# Build with multi stage

**Build concise images**

Hello everyone and welcome to the Docker course and its next learning session devoted to the creation of concise container images.

Today we will look into an interesting Docker technique named multi-stage builds.

As an example we will use very simple programs written in C++, Go and Python. But don't worry you don't need to know any of the programming languages to understand what we are going to talk about today.

We will continue using `lazydocker` tool, which is a simple terminal UI that makes it easy to manage Docker.

## Multi-stage builds

According to Docker documentation, multi-stage builds are useful to optimize Dockerfiles while keeping them easy to read and maintain.

To grasp what's hidden behind this definition let's see the technique on simple examples.

From introductory session we know that containers are self-contained units of software, meaning they have everything themselves to run the software components they consist of.

Software components can be written in any programming language. But each programming language has its own tools to build a working software components. The tools must be installed on a machine. Using containers we can install required tools into virtual environment keeping our own system intact.

Let's start from famous hello world example written in C++.

```sh
cat hello.cpp
```
```cpp
#include <iostream>

int main() {
  std::cout << "Hello, C++\n";
  return 0;
}
```

It's a code of simple program that prints out the greeting message into standard output.

Let's write a Dockerfile that using required tools will assemble an executable file and use the executable as an entrypoint.

```sh
cat Dockerfile.cpp.single
```
```Dockerfile
FROM alpine

RUN apk add g++

WORKDIR /src

COPY hello.cpp .

RUN g++ -o /bin/hello hello.cpp

ENTRYPOINT [ "/bin/hello" ]
```

We use `alpine` as the base image. Then we ask docker to execute the following steps in order to assemble our container image.
- Install C++ toolchain
- Create a working directory named `src`
- Copy the file containing our program source code
- Run the C++ tool to create an executable from the source and put it into file `/bin/hello`
- Use the executable as entrypoint

Let's build an image.

```sh
docker build . --file Dockerfile.cpp.single --tag cpp-single
```

Now we can run a container from the image we have just built.

```sh
docker run --rm cpp-single
```

Let's look into the image size.
We see that it takes about two hundred and forty megabytes just to print out a simple phrase. Of course real programs are more complicated and meaningful then this simple one. But quarter of one gig is a way too much even for a meaningul program written in C++. So why it has that big size?

It is because the image we have just created contains a full set of tools that we installed in order to build this simple app. It contains all the libraries required for C++ programs, even those that we din't use in our example. It also contains all the intermediate files the C++ tools have created while building an executable for us. So what can we do to optimize the size of the image?

Technicaly we could add RUN instuctions that will find and delete everythin we don't need to have in a final image. In this case we have to know where all the files we have to remove exactly reside. Which is inpractical, to be honest. There is a much better way.

Instead of removing things we don't need and actually don't aware of from the image, we can create a new image and put there only things we need and we know about.

Let's see how we can do it using Docker multi-stage buils.

```sh
cat Dockerfile.cpp.multi
```
```Dockerfile
FROM alpine AS build

RUN apk add g++

WORKDIR /src

COPY hello.cpp .

RUN g++ -static -o /bin/hello hello.cpp

FROM scratch

COPY --from=build /bin/hello /bin/hello

ENTRYPOINT [ "/bin/hello" ]
```

In a Dockerfile we can have as many [FROM] instructions as we need. Each the instruction introduces a stage which is unnamed be default. By giving it a name we can then refer the stage in [COPY] instructions.

In the Dockerfile we started stage named `build`, run all the instructions required to assemble an executable for our C++ program. Then we started a new unnamed stage. At this point Docker created a new empty container. Then we copied only our executable and set entrypoint.

We use the same [COPY] instruction as before but added `--from` option that refers to a stage.

Our final image is defined by the last stage in our Dockerfile.

Let's build an image from this new Dockerfile and review its size.

```sh
docker build . --file Dockerfile.cpp.multi --tag cpp-multi
```

The new image size is nine megabytes which is much better result. Let's try to run from the new image.

```sh
docker run --rm cpp-multi
```

We got the same output as before, meaning everything works as expected. Our new image contains only the binary and contains nothing at all from the first stage. If we look closely into the Dockerfile and the FROM instruction we used for the final stage, we would see it uses image named `scratch`. We won't find this image anywhere and won't be able to run a container from it. Such container doesn't exist. This is reserved name which instructs the Docker to create an absolutely empty image.

Therefore, with multi-stage builds, we use multiple [FROM] statements in our Dockerfile. Each [FROM] instruction can use a different base, and each of them begins a new stage of the build. We can selectively copy artifacts from one stage to another, leaving behind everything we don't want in the final image.

Please note that we can only get artifacts from other stages, it is not possible to use a tool installed into another stage by running it in context of current stage. For instance, if we have one stage with c++ compiler installed and we have another stage where we copied only source code files, we can't use [RUN] instruction that runs the compiler from other stage against files in the current stage.

Let's see another example, this time we will use program written in go.

```sh
cat hello.go
```
```go
package main

import "fmt"

func main() {
	fmt.Println("Hello, golang")
}
```

The program should do the same as the previous one, it should print out a greeting message. Let's look at the Dockerfile we are going to use to assemble an executable from this code.

```sh
cat Dockerfile.go.single
```
```Dockerfile
FROM golang as build

COPY hello.go /src/hello.go

RUN go build -o /bin/hello /src/hello.go

ENTRYPOINT [ "/bin/hello" ]
```

This time we start not from `alpine`, instead we use existing pre-built image that contains all the requred tools to build a program written in go. So we copy our source code file and using `go` tool build executable that we then set as container entrypoint.

Let's build an image.

```sh
docker build . --file Dockerfile.go.single --tag go-single
```

Let's run a container to verify the resulting image.

```sh
docker run --rm go-single
```

It works. But look at the image size. Almost a gigabyte to do a simple thing. What a waste of resources. Let's apply multi-stage builds technique.

```sh
cat Dockerfile.go.multi
```
```Dockerfile
FROM golang as build

COPY hello.go /src/hello.go

RUN go build -o /bin/hello /src/hello.go

FROM scratch

COPY --from=build /bin/hello /bin/hello

ENTRYPOINT [ "/bin/hello" ]
```

We named our first stage as `build`, added a new stage from `scratch` and copy executable from `build` to the final stage. That's it. Let's build and run.

```sh
docker build . --file Dockerfile.go.multi --tag go-multi
docker run --rm go-multi
```

It works and the size is less then two megabytes.

Let's try third example written in Python.

```sh
cat hello.py
```
```python
print('Hello, Python')
```

This oneliner is a valid python program that prints out the greeting message.

A Dockerfile for this program is the following.

```sh
cat Dockerfile.py.single
```
```Dockerfile
FROM alpine AS build

RUN apk add python3

COPY hello.py /src/

ENTRYPOINT [ "python3", "/src/hello.py" ]
```

Python is an iterpreted programming language, meaning we don't need to translate our code into an executable. So we instruct Docker to install python, copy script and use python to run our script as an entrypoint.

Let's try to build an image and run from it.

```sh
docker build . --file Dockerfile.py.single --tag py-single
docker run --rm py-single
```

Only fifty megabytes. Not bad.

The thing is that we installed only basic python infrastructure that allows us to write programs using standard python libraries. For real life applications size of an image can be much bigger depending on amount of additional python packages we will have to add.

Is there a way to optimize an image containing python base software components using an approach similar to what we've already seen?

There are several 3rd party tools that allow to create concise bundle for a python application. One of this tools is `pyinstaller`.

The tool analyzes python code, finds all the dependencies and translates everything into python byte code. So actually it produces a compiled version of python application. And it can package everything in a single executable file.

Let's write a Dockerfile to assemble image using pyinstaller.

```sh
cat Dockerfile.py.multi
```
```Dockerfile
FROM alpine AS build

RUN apk add \
  binutils \
  py3-pip

RUN pip install pyinstaller --break-system-packages

COPY hello.py /src/

RUN pyinstaller --onefile /src/hello.py

FROM alpine

COPY --from=build /dist/hello /bin/hello

ENTRYPOINT [ "/bin/hello" ]
```

This time we have to install additional system level tools and install not only `python` but also its package manager named `pip`. Then using the python package manager we install `pyinstaller`. Then we use `pyinstaller` as we used `c++` or `go` related tools to build an executable. And again, we copy the executable and use it as an entrypoint.

Let's build and run.

```sh
docker build . --file Dockerfile.py.multi --tag py-multi
docker run --rm py-multi
```

It works and new size is fourteen megabytes which is not a significant drop from fifty megs. But the size win will gain along with adding new python packages.

I showed you the python based example to demonstrate that every programming language has its own tools and techniques for its artifacts optimization. But from Docker standpoint the approach is the same. We use multi-stage builds and copy only optimized artifacts into a final image.

At the beginning we mentioned that multi-stage builds are useful to optimize Dockerfiles while keeping them easy to read and maintain. So the final image size optimization is not the main purpose of multi-stagge builds. Let's see how the technique can be used to optimize Dockerfile structure.

## Simplified example

We are going to use a simplified example that nevertheless captures the idea of using multi-stage builds.

Let's start from a single stage Dockerfile.

```sh
cat Dockerfile.poster.single
```
```Dockerfile
FROM alpine

RUN apk add figlet

RUN echo -e "keep calm\nand\ncontainerize" | figlet > poster

CMD ["cat", "poster"]
```

Here we add `figlet` tool and use it to write a message to the `poster` file. Then the final image will print out content of the file using linux command `cat`. Let's build and run the image.

```sh
docker build . --file Dockerfile.poster.single --tag poster-single
docker run --rm poster-single
```

By this example we mimic a process of creation of an executable applying a special tool to a source file. Then we use the obtained result as an image entrypoint.

Let's write a multi-stage variant of the Dockerfile.

```sh
cat Dockerfile.poster.multi
```
```Dockerfile
FROM alpine AS first

RUN apk add figlet

RUN echo -e "keep calm\nand\ncontainerize" | figlet > poster

FROM busybox

COPY --from=first poster poster

CMD ["cat", "poster"]
```

Here we start a new image from a different base and copy result from the first stage. The `busybox` image contains only a minimal set of common linux utilities. It's intent is to provide as much critical functionality of a linux command line environment as possible in a minimal size.

This enough for our task which is a printing out content of a file. Let's build and run an image again.

```sh
docker build . --file Dockerfile.poster.multi --tag poster-multi
docker run --rm poster-multi
```

Everything works and if we compare sizes of both images, we would see that the multi-stage based is twice smaller.

## Use a previous stage as a new stage

Now we can try a more complex Dockerfile.

```sh
cat Dockerfile.poster.big
```
```Dockerfile
FROM alpine AS build

RUN apk add figlet

FROM build AS poster1

RUN echo -e "keep calm\nand\ncontainerize" | figlet > poster

FROM build AS poster2

RUN echo -e "keep calm\nand\ndockerize" | figlet > poster

FROM busybox AS union

COPY --from=poster1 poster poster1
COPY --from=poster2 poster poster2

RUN cat poster1 >> poster
RUN cat poster2 >> poster

FROM busybox

COPY --from=union poster poster

CMD ["cat", "poster"]
```

We start with `build` stage that contains a tool that we are going to use on subsequest stages.
Then we create `poster1` stage. Take a look into the [FROM] instruction we use here. We start the new stage not from an image but from the previous stage. Actually, we create a clone of the `build` stage and name it `poster1`. On this stage we use `figlet` tool to create the `poster` file. We can use the tool because the stage cloned from another stage has all components and settings from the source stage.
Then we repeat the same for `poster2` stage. 
After that, we create a new stage named `union` that is not cloned from `build` stage.
We copy both posters and combine tham into one file.
And then we create unnamed stage that will be our final image.
Here we copy resulting file from `union` stage and set our entry point to call a command that will printout the file.

Let's try to build and use the resulting image.

```sh
docker build . --file Dockerfile.poster.big --tag poster-big
docker run --rm poster-big
```

This example shows how we can create stages that can be reused. For instance, if we have to create a final image that consists of several components written in go, we don't have to start a new image and install all the go tools for every stage that builds a particular component. We can define one stage that has all the required tools and create subsequent stages from it.

## Stop at a specific build stage

We know that Docker creates and keeps an intermediate image for every step or instruction in a Dockerfile. What if we have a pretty big Dockerfile with many stages and want to stop build at the particular stage for debugging purpose? We can use `--target` option of the [docker build] command. With this option we inform Docker to stop building after a certain stage completed. The final image in this case will be what the target stage defines.

Let's see it on an example.

```sh
docker build . --file Dockerfile.poster.big --target union --tag poster-union
```

We use the same dockerfile as before but set a target for the build command.

Docker stopped after union stage. If we check `lazydocker` we would see that history of the new `poster-union` image and see that its content corresponds to the `union` stage instuctions we defined in the Dockerfile.

The technique can be used not only for debugging purpose. We can have one Dockerfile that defines a set of images that have to be assembled as final images and have common stages defined in the Dockerfile. So we can reuse the same Dockerfile in several [docker build] commands each of which builds a particular image.

## Use an external image as a stage

So far we know that we can refer a stage in a [COPY] instuction as source of artifacts and in a [FROM] instructions as a base image.
It turnes out that we can use an existing image from remote registry not only in a [FROM] instruction but also in a [COPY] instraction. So we can copy artifacts from any image even that resides in a remote registry.

Let's see it on example.

```sh
cat Dockerfile.alpine-release
```
```Dockerfile
FROM busybox

COPY --from=alpine:3.15 /etc/alpine-release /workspace/release

CMD [ "cat", "/workspace/release" ]
```

Let's build the image.

```sh
docker build . --file Dockerfile.alpine-release --tag alpine-release
```

We see that Docker pulled refered alpine image. Let's run a container to verify the created image.

```sh
docker run --rm alpine-release
```

## Possible Dockerfile layout

```Dockerfile
FROM golang AS go-build
. . .
FROM gcc AS cpp-build
. . .
FROM go-build AS first
. . .
FROM go-build AS second
. . .
FROM cpp-build AS third
. . .
FROM scratch
COPY --from=first ...
COPY --from=second ...
COPY --from=third ...
. . .
```

## Epilogue

On today's session we used multi-stage builds technique and demonstrated how it can be applied to optimize size of a final container image and optimize structure of a Dockerfile.
We tried it on a few examples written in C++, go and Python, using tools specific for a particular programming language ecosystem. And we reviewed the example of Dockerfile that consists of reusable stages.

# References

[Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)

[Create Executable of Python Script using PyInstaller](https://datatofish.com/executable-pyinstaller/)

[Converting an image to ASCII image in Python](https://www.geeksforgeeks.org/converting-image-ascii-image-python/)

[COPY]: https://docs.docker.com/engine/reference/builder/#copy
[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[FROM]: https://docs.docker.com/engine/reference/builder/#from
[RUN]: https://docs.docker.com/engine/reference/builder/#run

---
**[Top](#)**
&emsp;[Course](/README.md)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

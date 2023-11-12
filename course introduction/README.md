**[Back](../README.md)**
&emsp;[Home](/README.md)

# Course introduction

**Be prepared and know what to expect**

The goal of this course is to learn how to use docker and the tools directly related to it via practical examples.

The skills acquired during the course should be sufficient to perform ninety-five percent of the tasks that you may encounter in your work.

There are no special requirements for the course participants. All you need is to be able to use your operating system command shell and be familiar with git version control system and its basic commands.

The course consits of ten learning sessions with a homework assignment for each.

During the learning sessions we will discuss tools and recommended techniques of their usage.

We will not dive deeply into the theory, instead we will try to focus purely on practical aspects and demonstrations of the tools being studied. But don't worry, the accompanying explanations will be enough so that you won't have any questions about what this or that method is used for and why it is used in this particular way and not otherwise.

Each session have a set of recommended materials that you can use to get more details about the session topic.

Of course you will have questions regarding the topics will be covered on sessions and about homework assignments. We will try to answer all your questions during the learning sessions.

## What is Docker?

In simple words Docker helps build lightweight and portable software containers that simplify application development, testing, and deployment.

### What are containers?

Shortly, containers are small and lightweight execution environments that make shared use of the operating system kernel but otherwise run in isolation from one another.

>Self-contained units of software you can deliver from a server over there to a server over there, from your laptop to EC2 to a bare-metal giant server, and it will run in the same way because it is isolated at the process level and has its own file system.

![The virtualization and container infrastructure](https://images.idgesg.net/images/article/2017/06/virtualmachines-vs-containers-100727624-orig.jpg)

## History of containers

| Year | Event | Details
|-|-|-
| **1979** | Unix V7 | Introduced [chroot] system call<br><br>Segregating file access for each process
| 2000 | FreeBSD Jails | Allows administrators to partition a FreeBSD computer system into several independent, smaller systems
| 2001 | Linux VServer | The jail mechanism that can partition resources (file systems, network addresses, memory) on a computer system
| 2004 | Solaris Containers | System resource controls and boundary separation<br><br>Snapshots and cloning
| 2005 | Open VZ (Open Virtuzzo) | Operating system-level virtualization technology
| **2006** | Process Containers | [cgroups] for limiting and isolating resource usage
| **2008** | LXC | First linux container management using [cgroups] and [Linux namespaces]
| 2011 | Warden | Isolate environments on any operating system
| 2013 | LMCTFY | Active development stopped in 2015
| **2013** | Docker | Used LXC, then libcontainer<br><br>Offers an entire ecosystem for container management.
| 2016 | The Importance of Container Security Is Revealed | The goal is to build secure containers from the ground up
| **2017** | Container Tools Become Mature | Hundreds of tools have been developed to make container management easier<br><br>Containerd<br>rkt<br>Kubernetes
| 2018 | The Gold Standard | The massive adoption of Kubernetes
| 2019 | A Shifting Landscape | New runtime engines now started replacing the Docker runtime engine

### Docker components

| Name | Purpose
|- |-
| Docker image | A portable, read-only, executable file containing the instructions for creating a container
| Dockerfile | A text file provides a set of instructions to build a container image
| Docker run utility | A tool to manage images and control containers
| Docker Hub | A registry where container images can be stored, shared, and managed
| Docker Engine | The core of Docker that includes a long-running daemon process, APIs and command-line interface
| Docker Machine | A tool used to install and manage Docker Engine on various virtual hosts or older versions of macOS and Windows

![Docker architecture](https://aurigait.com/wp-content/uploads/2023/10/docker-architecture.png)

### [Homework](./homework/README.md)

## Study materials

[Docker overview](https://capgemini.udemy.com/course/learn-docker/learn/lecture/7894186#overview)

[Introduction to Docker](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15717962#overview)

[Getting started Docker](https://capgemini.udemy.com/course/learn-docker/learn/lecture/15828544#overview)

[Docker on Mac](https://capgemini.udemy.com/course/learn-docker/learn/lecture/15828728#overview)

[Docker on Windows](https://capgemini.udemy.com/course/learn-docker/learn/lecture/15828724#overview)

[Installing Docker on Mac](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15705976#overview)

[Installing Docker on Windows](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15705124#overview)

### Links

[A brief history of containers](https://blog.aquasec.com/a-brief-history-of-containers-from-1970s-chroot-to-docker-2016)

[What is Docker? The spark for the container revolution](https://www.infoworld.com/article/3204171/what-is-docker-the-spark-for-the-container-revolution.html)

[chroot]: https://en.wikipedia.org/wiki/Chroot
[cgroups]: https://en.wikipedia.org/wiki/Cgroups
[Linux namespaces]: https://en.wikipedia.org/wiki/Linux_namespaces
---
>**[Back](../README.md)**
&emsp;[Home](/README.md)

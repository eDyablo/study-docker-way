**[Back](../README.md)**
&emsp;[Home](/README.md)

# Course introduction

**Be prepared and know what to expect**

Hello everyone and welcome to the Docker course and its introductory session.

My name is ... and I will be your trainer for the entire course.

The goal of this course is to learn how to use Docker and the tools directly related to it via practical examples.

The goal of this particular session is to give you an idea what the course is really about, what to expect and how to be prepared.

At the session we will also talk about what docker is, take a short tour into its history and see from which components it consists of.

## Cource composition and structure of learning sessions

So the course is about the Docker itself and the tools that are usually used with it. We are trying to make this course rather practical than theoretical with a focus on problems we are facing in a wild.

The skills acquired during the course should be sufficient to perform ninety-five percent of the tasks that you may encounter in your work.

There are no special requirements for the course participants. All that you need is to be able to use your operating system command-line shell and be familiar with git version control system and its basic commands.

The course consits of ten learning sessions with a homework assignment for each.

During the learning sessions we will discuss tools and recommended techniques of their usage.

We will not dive deeply into the theory, instead we will try to focus purely on practical aspects and demonstrations of the tools being studied. But don't worry, the accompanying explanations will be enough so that you won't have any questions about what this or that method is used for and why it is used in this particular way and not otherwise.

Each session have a set of recommended materials that you can use to get more details about the session topic.

Of course you will have questions regarding the topics being covered on a session and about homework assignments. We will try to answer all your questions during the learning sessions.

Each learning session is consists of four parts. It starts with demonstration part during which we will see how to use tools for a tasks related to the session topic.
The next part's purpose is for questions regarding the current session topic and questions that you may had after reading the sudying materials for the previous session. Then we will discuss issues occured while working on previous homework assignment. On the final part we will quickly review the assignment you will have to complete before the next learning session. So you'll have a chance to ask questions before they occur when you will be on your own.

During the demonstration part you may interrupt and ask questions but I encourage you to defer them to the second part if it's possible.

---
*Any questions so far?*

This is it about the course's purpose and structure and we are ready to actually start the course.

So lets jump right in.

## What is Docker?

In simple words Docker helps build lightweight and portable software containers that simplify application development, testing, and deployment.

Of course Docker is a lot more complicated than this simple definition. But from a user point of view it's just a command-line or UI tool that allows to create, maintain and manage containers on the user's system.

### What are containers?

Shortly, containers are small and lightweight execution environments that make shared use of the operating system kernel but otherwise run in isolation from one another.

Let's refer to Docker authors quote sounded on the PyCon conference in year 2013.

>Self-contained units of software you can deliver from a server over there to a server over there, from your laptop to EC2 to a bare-metal giant server, and it will run in the same way because it is isolated at the process level and has its own file system.

Again, there is a lot more behind this simple definition but fundamental idea is ability to use easy deployable self-contained software components running in isolation the same way anywhere.

But before containers were started circulating out we were using VMs for that purpose.

![The virtualization and container infrastructure](https://images.idgesg.net/images/article/2017/06/virtualmachines-vs-containers-100727624-orig.jpg)

Unlike virtual machines, containers use controlled portions of the host operating system’s resources, which means elements aren’t as strictly isolated as they would be on a VM.

Containers are significantly more lightweight and closer to the metal than virtual machines, but they do incur some performance overhead. If our workload requires bare-metal speed, a container will get us close but not all the way there.

### Containers advantages

Containers let applications and their environments be kept clean and minimal by isolating them.
Everytime we are running a container it starts from a clean environment not affected by other environments. Once it's done its job all the modification done to the container during its lifetime is wiped out. Except the case when we are intentionally maintaining its state.

Containers make it easier for developers to compose the building blocks of an application into a modular unit.
Because it's a self-contained component that consists of executables and environment sufficient to run these executables. At the same time, containers can easily communicate with each other or share data forming a complete application. Different applications can easily use the same container images avoiding duplication of effort to setup executables and environments.

Because containers are lightweight, developers can launch lots of them.
It's much easier or even possible to run dozens of containers on a single machine then run the same amount of virtual machines.

## History of containers

Actually It's been a long time since containers first came into scene.
Usually, for a better understanding of things, it is appropriate to refer to their history. From there we can get what inspired authors and see why things are what they are.

The history of containers begins as far back as 1979, when the chroot function appeared in the Linux system, which allowed the calling process to obtain isolated access to the file system.

In continuation of this, in the 2000s, active development of tools for creating isolated environments is underway. The term "jails" was coined. The jail mechanism allows partition resources like file systems, network addresses and memory on a single computer system.

In 2004 Solaris Containers added abitlity to make snapshots of the system, clone the snapshots and use them as separate environments.

Soon after that Open Virtuzzo brought system-level virtualization technology, thus hardware component become not required for this.

Another important milestone in the containers history is the appearance in 2006 of the [cgroups] mechanism that formerly known as *Process Containers*. The [cgroups] limits, accounts for, and isolates resources usage of a processes collection. 

Together with [Linux namespaces] [cgroups] gave birth to Linux Cotainers method know as [LXC]. This operating-system level virtualization method allows to run multiple isolated Linux systems on a host using a single Linux kernel without the need for starting any virtual machines, providing complete isolation of an application's view of the operating system.

This is exactly what containers are in nowadays.

But this is not the end of the story. From the moment of LXC appearance many questions and challenges arose. Like the idea of running the isolated environments on any operating system. So development was going on and in 2013 the Docker has come into play by offering an entire ecosystem for container management.

And even then the history of containers didn't run to its end.
Many questions regarding security were waiting for their resolution. Many attention was paid to the very significant aspect like scaling. So hundreds of tools have been developed to make container management easier. Systems like containerd and rkt(rocket) and Kubernetes were born.

And with the massive adoptation of Kubernetes the containers became The Gold Standard in 2018.

In present times new runtime engines now started replacing the Docker runtime engine.
But regardless of that containers and Docker have founded fundamental principals, techniques and practices that will stay.

So the knowledge you will get on the course will not lose its relevance.

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

As was mentioned, the Dotsker is an ecosystem. So let's see what composes it.

| Name | Purpose
|- |-
| Docker image | A portable, read-only, executable file containing the instructions for creating a container
| Dockerfile | A text file provides a set of instructions to build a container image
| Docker run utility | A tool to manage images and control containers
| Docker Hub | A registry where container images can be stored, shared, and managed
| Docker Engine | The core of Docker that includes a long-running daemon process, APIs and command-line interface
| Docker Machine | A tool used to install and manage Docker Engine on various virtual hosts or older versions of macOS and Windows
| Docker Compose | A command-line tool that uses [YAML] files to define and run multicontainer Docker applications
| Docker Desktop | A desktop application providing a user-friendly way to build and share containerized applications

![Docker architecture](https://aurigait.com/wp-content/uploads/2023/10/docker-architecture.png)

### Epilogue

So, today we have defined the course composition and structure of learning sessions. We've got a little familiar with docker and its components. We tried to understand its idea and origin by delving into containers history.

### [Homework](./homework/README.md)

## Study materials

[Docker docs](https://docs.docker.com/get-started/)

[Docker overview](https://capgemini.udemy.com/course/learn-docker/learn/lecture/7894186#overview)

[Introduction to Docker](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15717962#overview)

[Getting started with Docker](https://capgemini.udemy.com/course/learn-docker/learn/lecture/15828544#overview)

[Docker on Mac](https://capgemini.udemy.com/course/learn-docker/learn/lecture/15828728#overview)

[Docker on Windows](https://capgemini.udemy.com/course/learn-docker/learn/lecture/15828724#overview)

[Installing Docker on Mac](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15705976#overview)

[Installing Docker on Windows](https://capgemini.udemy.com/course/docker-tutorial/learn/lecture/15705124#overview)

### References

[A brief history of containers](https://blog.aquasec.com/a-brief-history-of-containers-from-1970s-chroot-to-docker-2016)

[What is Docker? The spark for the container revolution](https://www.infoworld.com/article/3204171/what-is-docker-the-spark-for-the-container-revolution.html)

[Docker Series – Blog 1: Getting Started with Docker and Building Your First Image](https://aurigait.com/blog/docker-series-blog-1-getting-started-with-docker-and-building-your-first-image/)

[cgroups]: https://en.wikipedia.org/wiki/Cgroups
[chroot]: https://en.wikipedia.org/wiki/Chroot
[Linux namespaces]: https://en.wikipedia.org/wiki/Linux_namespaces
[LXC]: https://en.wikipedia.org/wiki/LXC
[YAML]: https://en.wikipedia.org/wiki/YAML

---
**[Back](../README.md)**
&emsp;*[Top](./README.md)*
&emsp;[Home](/README.md)

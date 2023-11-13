**[Back](../README.md)**
&emsp;[Home](/README.md)

# Course introduction homework

## Goal
The goal of the exercise is to be able to successfully run the commands listed below.

```sh
docker system info
```
```sh
docker run
```
```sh
docker-compose up
```

## Steps

To accomplish the assignment do the following steps.

## Setup your system

Install docker and docker-compose using any suitable for your system(workstation) way.

You can find instructions on the [official Docker site](https://www.docker.com/get-started/).

## Setup your development environment

### Clone remote repository

Clone the repository into your local system and create your branch.

To clone the repository use one of the following commands.
```sh
git clone git@gitlab.lohika.com:study/docker/way.git ~/docker-course
```
```sh
git clone https://gitlab.lohika.com/study/docker/way.git ~/docker-course
```

Switch to the local repository directory.
```sh
cd ~/docker-course
```

To create branch use checkout command and name the branch according to your first and last names.
```sh
git checkout -b firstname-lastname
```

Once you've created the branch you have to push it into remote repository.
```sh
git push --set-upstream origin firstname-lastname
```

You could visit the [remote repository branches](https://gitlab.lohika.com/study/docker/way/-/branches) and check if your new branch is listed there.

### Change current directory

Switch to the homework assignment directory.

Assuming that your current working directory is your local repository root directory (see above), you can use the change directory command shown below.

```
cd 'course introduction/homework'
```

## Apply required modifications

Modify [`docker-compose.yaml`](./docker-compose.yaml) file to use `hello-seattle` container image and run the following commands.

## Run tests

Run the following commands shown below in the particular order they are listed.

```sh
docker system info > docker.info
docker run --rm hello-seattle > docker.hello
docker-compose up > compose.hello
docker-compose down
```

## Publish results

Commit and push `compose.hello`, `docker.hello` and `docker.info` files.

```sh
git add --all
git commit --all --message "hello docker"
git push
```

---
**[Back](../README.md)**
&emsp;*[Top](./README.md)*
&emsp;*[Homeworks](/README.md#homeworks)*
&emsp;[Home](/README.md)

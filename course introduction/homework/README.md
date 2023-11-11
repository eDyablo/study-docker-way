>**[Back](../README.md)**
&emsp;[Home](/README.md)

# Course introduction homework

Goal is to be able to successfully run the commands listed below.

```sh
docker system info
```
```sh
docker run
```
```sh
docker-compose up
```

Do the following steps.
1. Install docker and docker-compose using any suitable for your system(workstation) way.

2. Modify [`docker-compose.yaml`](./docker-compose.yaml) file to use `hello-seattle` container image and run the following commands.

```sh
docker system info > docker.info
docker run --rm hello-seattle > docker.hello
docker-compose up > compose.hello
docker-compose down
```

3. Commit and push `compose.hello`, `docker.hello` and `docker.info` files.

```sh
git add --all
git commit --all --message "hello docker"
git push
```

---
>**[Back](../README.md)**
&emsp;*[Top](./README.md)*
&emsp;*[Homeworks](/README.md#homeworks)*
&emsp;[Home](/README.md)

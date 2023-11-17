**[Session](../README.md)**
&emsp;[Course](/README.md)

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

### Setup your system

Install `docker` and `docker-compose` using any suitable for your system(workstation) way.

You can find instructions on the [official Docker site](https://www.docker.com/get-started/) or among the [session study materials](../README.md#study-materials).

### Setup your development environment

> :memo: The step is has to be done once for the entire course.

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
> :warning: Please don't forget to put your names instead of placeholders.
> :warning: Don not remove `student/` prefix from the branch name.

```sh
git checkout -b student/firstname-lastname
```

Once you've created the branch you have to push it into remote repository.
> :warning: Use the same branch name you have used in the command above.

```sh
git push --set-upstream origin student/firstname-lastname
```

You could visit the [remote repository branches](https://gitlab.lohika.com/study/docker/way/-/branches) and check if your new branch is listed there.

Once you've published your newly created branch the system automatically triggers pipeline that checks your homework assingments. You can see it by visiting [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) page and find pipeline referring your branch there.
> :memo: At this moment the pipeline for your branch should fail meaning that you have to complete the assignment.

### Change current directory

Switch to the homework assignment directory.

Assuming that your current working directory is your local repository root directory (see above), you can use the change directory command shown below.

```
cd 'course introduction/homework'
```

### Apply required modifications

Modify [`docker-compose.yaml`](./docker-compose.yaml) file to use `hello-seattle` container image and run the following commands.

### Run tests

Run the following commands shown below in the particular order they are listed.

```sh
docker system info > docker.info
docker run --rm hello-seattle > docker.hello
docker-compose up > compose.hello
docker-compose down
```

> :memo: Notice that docker-compose might be installed on your system as a docker plugin. In this case instead of ```docker-compose``` use ```docker compose```. You don't need to use them if the script above run with no error.

```sh
docker compose up > compose.hello
docker compose down
```

### Publish results

Commit and push `compose.hello`, `docker.hello` and `docker.info` files by running the following commands that commit and push all modified files from your local repository.

```sh
git add --all
git commit --all --message "hello docker"
git push
```

### Check the results

Once you've pushed the changes the system automatically triggers pipeline that check the results of the homework assignment.

To see the verification please visit [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) page and find the pipeline corresponding to your branch.
You will also receive an email regarding of the results.

### Troubleshooting

In case you got negative result you can use the [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) to find failed pipeline step and its logs.

Once you reviewed failures and made appropriate modifications you have to repeat [run tests](#run-tests) and the following steps.

> :memo: Use "lather, rinse, repeat" principle.

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)

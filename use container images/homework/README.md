**[Session](../README.md)**
&emsp;[Course](/README.md)

# **The Epic Story**<br>Use container images homework

## Goal

Be able to create, setup, run, check and stop a container using an existing image.

## Steps

To accomplish the assignment do the following steps.

### Setup your development environment

If you already have your environment setup you can skip the step, otherwise
please refer to [setup your development environment](/course%20introduction/homework/README.md#setup-your-development-environment) from [Course introduction](/course%20introduction/README.md) learing session.

### Update your development environment

Make sure that you have checked out correct branch. Please refer to [setup your development environment](/course%20introduction/homework/README.md#setup-your-development-environment) for more details.

Make sure that you have no uncommited modifications in your local repository branch.

Run the following steps to update your local repository branch with changes from remote repository main branch.

```sh
git fetch origin --prune
git merge origin/main -m update
git push
```

### Change current directory

Switch to the homework assignment directory.

Assuming that your current working directory is your local repository root directory (see above), you can use the change directory command shown below.

```sh
cd 'use container images/homework'
```

### Create container

Using [docker create] command create container named `heroic-show` from `alpine` image that should run command `sh /fable.sh` and have two environment variables `NAME` and `HERO`. Pass your name to the `NAME` variable, and for `HERO` variable use heroic name of your favorit superhero or use `valiant`.

Run the following instruction that using [docker ps] command stores status of the created container.
```sh
docker ps --filter name=heroic-show --all > heroic.emergence
```

### Copy script

Using [docker cp] command copy the `fable.sh` file into `/` path inside the container created on previous step.

Run the following instuction that by means of [docker diff] command stores changes made to files or directories on the container's filesystem.
```sh
docker diff heroic-show > heroic.spirit
```

### Start container

Using [docker start] command start the `heroic-show` container created on previous step.

Run the following instuction that using [docker ps] command stores status of the running container.
```sh
docker ps --filter name=heroic-show > heroic.deeds
```

### Get container logs

Run instruction below that by means of [docker logs] command stores log messages of the running container.
```sh
docker logs --timestamps heroic-show > heroic.tale
```

### Stop container and clean up

Run the following [docker stop] command to stop running `heroic-show` container.
```sh
docker stop heroic-show
```

By means of [docker rm] commmand shown below remove the stopped `heroic-show` container.
```sh
docker rm heroic-show
```

### Publish results

Commit and push all modified files by running the following commands.

```sh
git add --all
git commit --all --message 'epic story'
git push
```

### Check the results

Once you've pushed the changes the system automatically triggers pipeline that check the results of the homework assignment.

To see the verification please visit [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) page and find the pipeline corresponding to your branch.
You will also receive an email regarding of the results.

### Troubleshooting

In case you got negative result you can use the [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) to find failed pipeline step and its logs.

Once you reviewed failures and got understanding what should be corrected you have to repeat steps starting from [container creation](#create-container).

[docker cp]: https://docs.docker.com/engine/reference/commandline/cp/
[docker create]: https://docs.docker.com/engine/reference/commandline/create/
[docker diff]: https://docs.docker.com/engine/reference/commandline/diff/
[docker logs]: https://docs.docker.com/engine/reference/commandline/logs/
[docker ps]: https://docs.docker.com/engine/reference/commandline/ps/
[docker rm]: https://docs.docker.com/engine/reference/commandline/rm/
[docker start]: https://docs.docker.com/engine/reference/commandline/start/
[docker stop]: https://docs.docker.com/engine/reference/commandline/stop/

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

**[Session](../README.md)**
&emsp;[Course](/README.md)

# **Bon Appetit!**<br>Evolve a container image homework

## Goal

Create a new image from existing one, modify its content and behaviour and publish the modified image.

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
git merge origin/main --strategy-option theirs -m update
git push
```

> :memo: At this moment the pipeline for your branch should fail meaning that you have to complete the assignment.

### Change current directory

Switch to the homework assignment directory.

Assuming that your current working directory is your local repository root directory (see above), you can use the change directory command shown below.

```sh
cd 'evolve a container image/homework'
```

### Start a new container from base image

Using [docker run] command run a new autodisposable container from `alpine` image and running in the interactive mode.

### Add required 3rd party software

By means of `apk` package manager install the `figlet` command line tool into the container created on previous step.

```sh
apk add figlet
```

Using [docker commit] command commit the aplied modifications to the `jadlospis` image providing `add figlet` message.

### Copy script

Copy `menu.sh` script resides in the `homework` directory into the running container via [docker cp] command.

By means of [docker commit] command commit the aplied modifications to the `jadlospis` image providing `copy script` message.

### Set command and evironment values

Set the image command and its `DISH` environment value. For the command use `sh /menu.sh` and for the environment value use your favorite dish name or use `pizza` if you have no preferences.

You can use [docker run] of [docker create] command and specify the command and the environment value by using `--env` option. Or you can use [docker create] to create a non-running container and then via [docker commit] command(s) and its `--change` option set the image command and the image environment value. See the examples of the command below.

```sh
docker commit --message 'set command' --change 'CMD sh /menu.sh' menuil jadlospis
docker commit --message 'set env' --change 'ENV DISH=stew' menuil jadlospis
```

If you didn't use [docker commit] command to set the image command and environment value then you have to commit the aplied modifications to the `jadlospis` image providing `set command and env` message.

### (Optional) Change default figlet font
If you like you can also set `FONT` environment value. The value is the name of a font file that were added to the image during `figlet` installation. You can list all the available font names by running the following shell command inside the container.
```sh
find / -name *.flf -exec basename {} .flf \;
```

### Publish the image

Login to your account on [Dockerhub] via [docker login] command.

By means of [docker tag] command tag the image you've created and modified on previous steps. Please use `jadlospis` as the image name and your first and last names as the image tag as shown on the example below.
```sh
account/jadlospis:firstname-lastname
```
:warning: The `firstname-lastname` tag must be the same as a part of your git branch name without `student/` prefix. Use `git branch` command to see the branch name.

Using [docker push] command publish the image on [Dockerhub].

### Provide your Dockerhub account name

Put your [Dockerhub] account name into `dockerhub-account.txt` file that is alredy exist in the `homework` directory.

:warning: Do not put a password or any other information into the file.

### Publish the change

Commit and push modified `dockerhub-account.txt` by running the following commands.

```sh
git add dockerhub-account.txt
git commit --all --message 'bon appetit'
git push
```

### Clean up

You can clean up all dangling images by [docker image prune] command.

### Check the results

Once you've pushed the changes the system automatically triggers pipeline that check the results of the homework assignment.

To see the verification please visit [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) page and find the pipeline corresponding to your branch.
You will also receive an email regarding of the results.

### Troubleshooting

In case you got negative result you can use the [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) to find failed pipeline step and its logs.

Once you reviewed failures and got understanding what should be corrected you have to trigger the pipeline again. To do so please issue the following commands.
```sh
git commit --allow-empty -m 'trigger pipeline'
git push
```
> :memo: Use "lather, rinse, repeat" principle.

[docker commit]: https://docs.docker.com/engine/reference/commandline/commit/
[docker cp]: https://docs.docker.com/engine/reference/commandline/cp/
[docker create]: https://docs.docker.com/engine/reference/commandline/create/
[docker image prune]: https://docs.docker.com/engine/reference/commandline/image_prune/
[docker login]: https://docs.docker.com/engine/reference/commandline/login/
[docker push]: https://docs.docker.com/engine/reference/commandline/push/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/
[docker tag]: https://docs.docker.com/engine/reference/commandline/tag/
[dockerhub]: https://hub.docker.com/

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

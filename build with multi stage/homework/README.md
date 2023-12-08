**[Session](../README.md)**
&emsp;[Course](/README.md)

# **Dear Santa...**<br>Build with multi stage homework

## Goal

Write a dockerfile consists of two stages with one stage uses artifact from another one.

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
cd 'build with multi stage/homework'
```

### Write Dockerfile content

You have to write a two stage Dockerfile.

First stage should be based on `alpine` image and install `figlet` tool using `apk add figlet` command.

Then on the first stage you have to copy provided `letter.sh` file and run it using `sh letter.sh` command by passing to it a short text that describes what you would like to get from Santa this Christmas. Use the following as an example of the command.

```sh
sh letter.sh Christmas elk pattern socks
```

This will create a file named `letter-to-santa`.

The second stage should be base on `busybox` image of version `1.36.1` (use image name tag to specify the version).

On the second stage you have to copy file `letter-to-santa` from the first stage.

Then copy provided `envelop.sh` file and use it as image `entrypoint` or `cmd`. Use the following command for the entrypoint or cmd.

```sh
sh evelop.sh
```

### Test before publishing

You can test your solution by building an image and running container from the image. Use the following [docker build] and [docker run] commands as an example.

```sh
docker build . --tag scrisoare-de-craciun
```

```sh
docker run --rm scrisoare-de-craciun
```

### Publish the change

Commit and push modified `Dockerfile` by running the following commands.

```sh
git add Dockerfile
git commit --all --message 'dear santa'
git push
```

## Check the results

Once you've pushed the changes the system automatically triggers pipeline that check the results of the homework assignment.

To see the verification please visit [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) page and find the pipeline corresponding to your branch.
You will also receive an email regarding of the results.

## Troubleshooting

In case you got negative result you can use the [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) to find failed pipeline step and its logs.

Once you reviewed failures and got understanding what should be corrected you have to [publish the change](#publish-the-change).

:memo: Use "lather, rinse, repeat" principle.

## Clean up

You can clean up all dangling containers by [docker container prune] command.

Then you can clean up all dangling images by [docker image prune] command.

[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[docker container prune]: https://docs.docker.com/engine/reference/commandline/container_prune/
[docker image prune]: https://docs.docker.com/engine/reference/commandline/image_prune/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

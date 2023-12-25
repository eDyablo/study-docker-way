**[Session](../README.md)**
&emsp;[Course](/README.md)

# **It's Not a Cow**<br>Advanced container build techniques homework

## Goal

Write a dockerfile for creating an image containing build triggers that can be used to build other images from.

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

:memo: At this moment the pipeline for your branch should fail meaning that you have to complete the assignment.

### Change current directory

Switch to the homework assignment directory.

Assuming that your current working directory is your local repository root directory (see above), you can use the change directory command shown below.

```sh
cd 'advanced container build techniques/homework'
```

### Write Dockerfile content

There is already the `Dockerfile` that you should not modify.

Your task is to create a file named `Dockerfile.template` that should define an image that has the following requirements.

The image uses `alpine` as its base. See [FROM] instruction.

It has the `cowsay` tool installed by running the command below. See [RUN] instruction.

```sh
apk add --no-cache --update cowsay --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
```

The image contains `transform.sh` script that can be copied from provided file.

It should define triggers that copy content of `src` directory from Docker Context into `/src` directory in the image file system and run `transform.sh` script by executing the following command. See [ONBUILD], [COPY] and [RUN] instructions.

```sh
sh transform.sh
```

It should define triggers that add two labels, `org.opencontainers.image.revision` and `org.opencontainers.image.authors`. These labels must get their values from `REVISION` and `AUTHOR` build arguments being provided during image build. See [ONBUILD], [LABEL] and [ARG] instructions.

### Test before publishing

You can test your solution by building images and running a container.

Build template image using [docker build] command.

```sh
docker build --file Dockerfile.template . --tag not-a-cow-template
```

Build image from the template using [docker build] command.

```sh
docker build . --build-arg BASE_IMAGE=not-a-cow-template --tag not-a-cow
```

Create `src` directory and put there a file containing any text.
And run a container by means of [docker run] command.

```sh
docker run --rm not-a-cow
```

### Publish the change

Commit and push modified `Dockerfile.template` by running the following commands.

```sh
git add Dockerfile.template
git commit --all --message 'not a cow'
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

[ARG]: https://docs.docker.com/engine/reference/builder/#arg
[COPY]: https://docs.docker.com/engine/reference/builder/#copy
[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[docker container prune]: https://docs.docker.com/engine/reference/commandline/container_prune/
[docker image prune]: https://docs.docker.com/engine/reference/commandline/image_prune/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/
[ENTRYPOINT]: https://docs.docker.com/engine/reference/builder/#entrypoint
[FROM]: https://docs.docker.com/engine/reference/builder/#from
[LABEL]: https://docs.docker.com/engine/reference/builder/#label
[ONBUILD]: https://docs.docker.com/engine/reference/builder/#onbuild
[RUN]: https://docs.docker.com/engine/reference/builder/#run
[VOLUME]: https://docs.docker.com/engine/reference/builder/#volume
[WORKDIR]: https://docs.docker.com/engine/reference/builder/#workdir

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

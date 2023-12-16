**[Session](../README.md)**
&emsp;[Course](/README.md)

# **The journey**<br>Persistence homework

## Goal

Write a dockerfile that uses volumes to store configuration, persiste state, and to write generated files.

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
cd 'persistence/homework'
```

### Write Dockerfile content

Use `alpine` image as base in [FROM] instruction.

Install `figlet` tool using [RUN] instruction and `apk add figlet` command.

Copy provided `initialize.sh` and `entrypoint.sh` files into image filesystem. Use [COPY] instruction.

Use `initialize.sh` in [ENTRYPOINT] that must run the script via command `sh initialize.sh`

Using [VOLUME] instruction declare three volumes for the following directories.
- `/config`
- `/state`
- `/workspace`

The `config` and `state` volumes should be pre-populated by runing `initialize.sh` script. Use [RUN] instruction to execute `sh initialize.sh` command.

The `workspace` volume should be set as image [WORKDIR].

### Provide input data

In provided `itinerary` file write at least 3 different places you would like to visit. Use new line for each place.

:warning: Please add empty line at the end of the `itinerary` file.

### Test before publishing

You can test your solution by building an image, running container, attach volumes and host's directories to image mount points. Use the following [docker build] and [docker run] commands as an example.

```sh
docker build . --tag calatorie
```

#### Test volumes set

```sh
docker image inspect clatoria --format '{{ .Config.Volumes }}'
```
```
map[/config:{} /state:{} /workspace:{}]
```

#### Test pre-populated volumes

Create container.

```sh
docker create --name voiaj calatorie
```

Run disposable busybox container that prints out content of pre-populated `fonts` file from `/config` mount point.

```sh
docker run --rm --volumes-from voiaj busybox sh -c 'cat /config/fonts'
```

You sould see a list of fonts.

#### Test state persistence

Run the following command multiple times.

```sh
docker run --rm --mount type=volume,src=calatorie-state,dst=/state calatorie "Hell's Kitchen"
```

You should see the number increasing.

### Publish the change

Commit and push modified `Dockerfile` adn `itinerary` by running the following commands.

```sh
git add Dockerfile itinerary
git commit --all --message 'happy journey'
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

To remove volumes use [docker volume rm] and [docker volume prune] commands.

[COPY]: https://docs.docker.com/engine/reference/builder/#copy
[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[docker container prune]: https://docs.docker.com/engine/reference/commandline/container_prune/
[docker image prune]: https://docs.docker.com/engine/reference/commandline/image_prune/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/
[docker volume prune]: https://docs.docker.com/engine/reference/commandline/volume_prune/
[docker volume rm]: https://docs.docker.com/engine/reference/commandline/volume_rm/
[ENTRYPOINT]: https://docs.docker.com/engine/reference/builder/#entrypoint
[FROM]: https://docs.docker.com/engine/reference/builder/#from
[RUN]: https://docs.docker.com/engine/reference/builder/#run
[VOLUME]: https://docs.docker.com/engine/reference/builder/#volume
[WORKDIR]: https://docs.docker.com/engine/reference/builder/#workdir

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

**[Session](../README.md)**
&emsp;[Course](/README.md)

# **Twinkle, twinkle, little star...**<br>Networking homework

## Goal

Write a dockerfile consists that can be connected on a port.

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
cd 'networking/homework'
```

### Write Dockerfile content

Use `alpine` or `busybox` as base image.

Copy provided `voice.sh` and `lullabay.txt` files into image file system.

Set entrypoint to run `voice.sh` shell script.

Define environment variable `PORT` equal to 50000 + year of your birth (or 2008).

Expose the port.

### Test before publishing

You can test your solution by building an image, running container attached to host network, and connect to it with web browser. Use the following [docker build] and [docker run] commands as an example. To connect use localhost:port in browser address bar.

```sh
docker build . --tag clarke
```

```sh
docker run --rm --network host clarke
```

### Publish the change

Commit and push modified `Dockerfile` by running the following commands.

```sh
git add Dockerfile
git commit --all --message 'twinkle twinkle'
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

If you created custom networks, you can remove them by [docker network prune] command.

[docker build]: https://docs.docker.com/engine/reference/commandline/build/
[docker container prune]: https://docs.docker.com/engine/reference/commandline/container_prune/
[docker image prune]: https://docs.docker.com/engine/reference/commandline/image_prune/
[docker network prune]: https://docs.docker.com/engine/reference/commandline/network_prune/
[docker run]: https://docs.docker.com/engine/reference/commandline/run/

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

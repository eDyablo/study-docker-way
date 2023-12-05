**[Session](../README.md)**
&emsp;[Course](/README.md)

# **Hoist a flag**<br>Build with dockerfile homework

## Goal

Write a dockerfile that can be used to create and run a container as an executable that receives command line arguments.

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
cd 'build with dockerfile/homework'
```

### Write Dockerfile content

Write a dockerfile to build an image for a container based on `alpine` and can be run as an executable that prints all passed arguments in ASCII art using `figlet` tool.
It must display some default text when no argument specified. As the default text please use any short quote that you like the most. For instance, you can use *"Learning never exhausts the mind"* or *"Develop a passion for learning"* or *"Change is the end result of all true learning"*, or use your first and last names if you don't like quotes.

Use provided `flagpole.sh` script as the image entrypoint.

There must be a working directory defined for the image.

Put the entrypoint script into directory different from image working directory.

The image must have one label named `author` and value equal to your git repository branch name without `student/` prefix.

The image must allow to select a font via `FONT` environment variable with default value from the list below.
- banner
- big
- block
- bubble
- digital
- lean
- mini
- script
- shadow
- slant
- small
- smscript
- smshadow
- smslant

### Publish the change

Commit and push modified `Dockerfile` by running the following commands.

```sh
git add Dockerfile
git commit --all --message 'hoist a flag'
git push
```

## Check the results

Once you've pushed the changes the system automatically triggers pipeline that check the results of the homework assignment.

To see the verification please visit [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) page and find the pipeline corresponding to your branch.
You will also receive an email regarding of the results.

## Troubleshooting

In case you got negative result you can use the [pipelines](https://gitlab.lohika.com/study/docker/way/-/pipelines?scope=branches) to find failed pipeline step and its logs.

Once you reviewed failures and got understanding what should be corrected you have to [publish the change](#publish-the-change).

> :memo: Use "lather, rinse, repeat" principle.

## Clean up

You can clean up all dangling containers by [docker container prune] command.

Then you can clean up all dangling images by [docker image prune] command.

[docker container prune]: https://docs.docker.com/engine/reference/commandline/container_prune/
[docker image prune]: https://docs.docker.com/engine/reference/commandline/image_prune/

---
**[Top](#)**
&emsp;[Session](../README.md)
&emsp;[Course](/README.md)
&emsp;[Homeworks](/README.md#homeworks)
<div align="right">[:loudspeaker: Report issue](https://gitlab.lohika.com/study/docker/way/-/issues/new)</div>

# ci-fly-runner
A "Fly" Docker container for running against Concourse.

## Dockerfile
The Dockerfile requires one build argument: "flyversion". This can either be passed in using the command line argument "--build-arg flyversion=x.x.x" or can be passed via the Concourse pipeline "build_args".

Command line example:
```bash
docker build --build-arg flyversion=5.0.0 . -t ci-fli-runner:5.0.0
```

Pipeline example using hard-coded build args:
```yaml
- put: docker-registry
  params:
    build: git-fly-dockerfile
    build_args:
      flyversion: 4.2.1
```

Pipeline example using input file (the file will have been created in a previous step).
```yaml
- put: docker-registry
  params:
    build: git-fly-dockerfile
    build_args_file: docker-build-args/flyversion.json
```

## Docker-tags
Use this file to define the tags that will be added to the container, and the version of Fly to be downloaded and installed in the container.
If multiple tags are required (i.e. the Fly version and 'latest'), they should be separated by spaces.

Examples:

Create a container with Fly version 4.2.1 tagged as 'latest':
```
4.2.1 latest
```
Create another with Fly version 3.14.1, not tagged latest:
```
3.14.1
```

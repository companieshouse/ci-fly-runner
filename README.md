# ci-fly-runner
A "Fly" Docker container for running against Concourse. Note that this is intended to be run from a Concourse pipeline.

## Dockerfile
The Dockerfile requires one build argument: "fly_version". This should be passed via the Concourse pipeline parameter "build_args_file" or "build_args" but for testing can also be passed in using a command line argument.

Pipeline example using input file (the file will have been created in a previous pipeline step).
```yaml
- put: docker-registry
  params:
    build: git-fly-dockerfile
    build_args_file: docker-build-args/flyversion.json
```

Pipeline example using hard-coded build args:
```yaml
- put: docker-registry
  params:
    build: git-fly-dockerfile
    build_args:
      flyversion: 4.2.1
```

Command line example:
```bash
docker build --build-arg fly_version=5.0.0 . -t ci-fli-runner:5.0.0
```

## fly-version
This file is read by the Concourse pipeline. Use this file to define the version of Fly to be downloaded and installed in the container and the tags that will be added to the container.
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

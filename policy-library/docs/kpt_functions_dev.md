# Dev Guide for the Policy Library KPT Functions


## Tests
Tests use the Jasmine framework and can be run with npm or with docker.

### Run with Node
```
npm --prefix ./bundler test
```

### Run with Docker
```
make docker_test_kpt
```

## Functions

### Get Policy Bundle

To build a Docker image for this function.

```
make docker_build_kpt_bundle
```

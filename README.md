# chart-metadata

Update Helm chart metadata and ensure global values required the cray-service base chart are set.

![Build image status](https://github.com/Cray-HPE/chart-metadata/actions/workflows/build-image.yaml/badge.svg)

## Usage

Run with `--help` to see the available options:

```
$ docker run --rm artifactory.algol60.net/csm-docker/stable/chart-metadata --help
usage: chart-metadata [-h] [-n NAME] [-v VERSION] [-a APP_VERSION]
                      [-i NAME IMAGE] [-l LICENSE] [--cray-service-globals]
                      [CHART-DIR]

positional arguments:
  CHART-DIR             Chart directory

options:
  -h, --help            show this help message and exit
  -n NAME, --name NAME  Set chart name
  -v VERSION, --version VERSION
                        Set chart version
  -a APP_VERSION, --app-version APP_VERSION
                        Set chart appVersion
  -i NAME IMAGE, --image NAME IMAGE
                        Set or update artifacthub.io/images annotation
  -l LICENSE, --license LICENSE
                        Set artifacthub.io/license annotation
  --cray-service-globals
                        Update global values expected by the cray-service base
                        chart
```

By default, `CHART-DIR` defaults to the current directory, which defaults to
`/chart` in the image.

### Update Chart version and appVersion

This simplest use-case is to update the `version` and `appVersion` fields in
Chart.yaml:

```
$ docker run --rm --user $(id -u):$(id -g) -v $(pwd):/chart \
  artifactory.algol60.net/csm-docker/stable/chart-metadata \
  --version 1.3.5 --app-version 2.4.6
```

```
$ docker run --rm -i artifactory.algol60.net/docker.io/mikefarah/yq:4 \
  eval '.version, .appVersion' - < Chart.yaml
1.3.5
2.4.6
```

### Update cray-service global values

If the chart uses the `cray-service` base chart, then use
`--cray-service-globals` to ensure that `global` values in values.yaml are
updated consistent with what is in Chart.yaml:

```
$ docker run --rm --user $(id -u):$(id -g) -v $(pwd):/chart \
  artifactory.algol60.net/csm-docker/stable/chart-metadata \
  --name my-chart --version 1.3.5 --app-version 2.4.6 \
  --cray-service-globals
```

```
$ docker run --rm -i artifactory.algol60.net/docker.io/mikefarah/yq:4 \
  eval '.global' - < values.yaml
chart:
  name: my-chart
  version: 1.3.5
appVersion: 2.4.6
```

### Update artifacthub.io/images annotation

Set or update the `artifacthub.io/images` annotation using `-i NAME IMAGE`. The
`-i` flag may be specified multiple times to set or update as many images as
necessary. If the given `NAME` is already defined in the
`artifacthub.io/images` annotation, `-i NAME IMAGE` will update it in-place;
otherwise, a new list item is appended to the end:

```
$ docker run --rm --user $(id -u):$(id -g) -v $(pwd):/chart \
  artifactory.algol60.net/csm-docker/stable/chart-metadata \
  --app-version 2.4.6 \
  -i my-image artifactory.algol60.net/csm-docker/stable/my-image:2.4.6
```

```
$ docker run --rm -i artifactory.algol60.net/docker.io/mikefarah/yq:4 \
  eval '.appVersion' - < Chart.yaml
2.4.6
$ docker run --rm -i artifactory.algol60.net/docker.io/mikefarah/yq:4 \
  eval '.annotations."artifacthub.io/images"' - < Chart.yaml
- name: my-image
  image: artifactory.algol60.net/csm-docker/stable/my-image:2.4.6
```

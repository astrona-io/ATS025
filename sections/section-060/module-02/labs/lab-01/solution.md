---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-02/labs/lab-01
```

## Step 1: Save the chart and install revision 1

Save the four chart files from the task under a directory named `chart`, so that `chart/templates/` holds the two templates. Check the chart before you install it:

```sh
helm lint chart
helm template scout chart --namespace starfleet --set replicaCount=2
```

`helm lint` reports problems in the chart. `helm template` prints the YAML that Helm would send, and it should show `replicas: 2` and the image `docker.io/library/busybox:1.37.0`. Now install the release:

```sh
helm install scout chart --namespace starfleet --set replicaCount=2 --wait --timeout 120s
helm list --namespace starfleet
```

`helm list` shows the release `scout` with the status `deployed` and the revision `1`. Helm stored the release record in a Secret named `sh.helm.release.v1.scout.v1`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-02/labs/lab-01 --keep
```

The release check, the workload check for two replicas and the ownership check pass. The history and values checks fail, because there is only one revision.

## Step 2: Upgrade to revision 2

```sh
helm upgrade scout chart --namespace starfleet --set replicaCount=3 --set logLevel=debug --wait --timeout 120s
helm history scout --namespace starfleet
```

The history lists revision 1 as `superseded` and revision 2 as `deployed`. The Deployment now has three replicas and `LOG_LEVEL` is `debug`. You can read the values that Helm recorded for each revision:

```sh
helm get values scout --namespace starfleet --revision 1
helm get values scout --namespace starfleet --revision 2
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-02/labs/lab-01 --keep
```

The values check passes now. The history check and the workload check still fail, because the release is not rolled back yet.

## Step 3: Roll back to revision 1

```sh
helm rollback scout 1 --namespace starfleet --wait --timeout 120s
helm history scout --namespace starfleet
kubectl -n starfleet get deployment scout
```

The history shows a third revision with the description `Rollback to 1`. The Deployment returns to two replicas and `LOG_LEVEL` `info`, because a rollback applies the stored manifest of revision 1.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-02/labs/lab-01 --keep
```

All checks pass. Clean up when you are done:

```sh
astrona destroy ats-025-lab-060-02-01
```

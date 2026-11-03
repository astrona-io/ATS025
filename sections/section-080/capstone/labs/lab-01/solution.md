---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/capstone/labs/lab-01
```

## Step 1: Publish the type

Save this as `crd-mission.yaml`:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: missions.training.astrona.io
spec:
  group: training.astrona.io
  scope: Namespaced
  names:
    kind: Mission
    plural: missions
    singular: mission
    shortNames:
      - msn
  versions:
    - name: v1
      served: true
      storage: true
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Phase
          type: string
          jsonPath: .spec.phase
        - name: Crew
          type: integer
          jsonPath: .spec.crewSize
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required:
                - callSign
                - phase
              x-kubernetes-validations:
                - rule: "self.callSign == oldSelf.callSign"
                  message: "callSign cannot be changed after creation"
              properties:
                callSign:
                  type: string
                phase:
                  type: string
                  enum:
                    - Planned
                    - Active
                    - Done
                crewSize:
                  type: integer
                  minimum: 1
                  maximum: 20
                  default: 3
            status:
              type: object
              x-kubernetes-preserve-unknown-fields: true
```

Apply it, wait for the type, and submit:

```sh
kubectl apply -f crd-mission.yaml
kubectl wait --for=condition=Established crd/missions.training.astrona.io --timeout=60s
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/capstone/labs/lab-01 --keep
```

The checks for the schema, the defaults, the immutable field, the subresource and the columns pass. The operator checks fail.

## Step 2: Wire the operator

```sh
kubectl -n mission-system create serviceaccount mission-operator
kubectl -n mission-system set serviceaccount deployment/mission-operator mission-operator
kubectl create clusterrole mission-operator \
  --verb=get,list,watch,update,patch --resource=missions.training.astrona.io,missions.training.astrona.io/status
kubectl create clusterrolebinding mission-operator \
  --clusterrole=mission-operator --serviceaccount=mission-system:mission-operator
```

The role from the last two commands has the mission rule only. Add the lease and event rules by editing the ClusterRole:

```sh
kubectl patch clusterrole mission-operator --type=json -p '[
  {"op":"add","path":"/rules/-","value":{"apiGroups":["coordination.k8s.io"],"resources":["leases"],"verbs":["get","list","watch","create","update","patch"]}},
  {"op":"add","path":"/rules/-","value":{"apiGroups":[""],"resources":["events"],"verbs":["create","patch"]}}
]'
kubectl -n mission-system rollout status deployment/mission-operator --timeout=120s
kubectl auth can-i delete nodes --as=system:serviceaccount:mission-system:mission-operator
```

The last command prints `no`. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/capstone/labs/lab-01 --keep
```

The identity and permission checks pass.

## Step 3: Create the first Mission

```sh
kubectl apply -f - <<'MISSION'
apiVersion: training.astrona.io/v1
kind: Mission
metadata:
  name: apollo
  namespace: starfleet
spec:
  callSign: apollo-one
  phase: Planned
MISSION
kubectl -n starfleet get missions
```

The list shows the columns `PHASE` and `CREW`, and the crew is 3 because the API server applied the default.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/capstone/labs/lab-01 --keep
```

All checks pass. Clean up when you are done:

```sh
astrona destroy ats-025-lab-080-capstone-01
```

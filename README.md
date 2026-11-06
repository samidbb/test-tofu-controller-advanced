# Tofu controller

## Requirement

* Local Kubernetes cluster distribution like minikube, kind, k3s, etc.
* gh cli
* flux cli
* OpenTofu

## Usefull links

* https://fluxcd.io/flux/installation/bootstrap/github/#bootstrap-without-a-github-pat
* https://flux-iac.github.io/tofu-controller/

## Create local cluster

Create a local Kubernetes cluster in any fashion you like. I use minikube.

```bash
minikube start --wait=all
minikube update-context
```

## Create a public repository in your own GitHub account

Create a public repository and clone it.

```bash
gh repo create <OWNER>/<NAME> --public
```

## Bootstrap fluxcd v2

Bootstrap fluxcd using your private key.

```bash
flux bootstrap git \
  --url=ssh://git@github.com/samidbb/test-tofu-controller-advanced \
  --branch=main \
  --private-key-file=~/gh_ssh_pv.key \
  --path=/clusters/minikube
```

## Install tofu-controller

Add these manifests to your folder `clusters/minikube/tofu-controller.yaml`.

Verify that it works with `flux get all`.

## Create AWS secrets
```bash
kubectl -n flux-system create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
```

## Add OpenTofu code and a Terraform resource

Create a folder in the repository root called `infra/` and add a file called `infra/main.tf`. This is where our OpenTofu code will go eventually.

Then deploy an AWS secret:

```
kubectl -n flux-system create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
```

It is also possible to use local capability credentials (required to already be logged in with `go-aws-sso`).

```bash
aws_creds="$(aws configure export-credentials --format env-no-export)"

printf '%s\n' "$aws_creds" |
  kubectl create secret generic aws-credentials \
    --namespace flux-system  \
    --from-env-file=/dev/stdin \
    --dry-run=client -o yaml | kubectl apply -f -
```

Lastly add this `Terraform` resource to the folder `clusters/minikube/terraform.yaml`.


## Enable branch-planner and access to PRs
Generate Github API token and create a kubernetes secrets to be accessible for branch-planner:
```
export GITHUB_TOKEN=$(gh auth token)

kubectl create secret generic branch-planner-token \
    --namespace=flux-system \
    --from-literal="token=${GITHUB_TOKEN}"
```

## Additionally

Look into the following topics:

* Locate plans and states as Kubernetes Secrets
* Try backup and restore of state https://flux-iac.github.io/tofu-controller/use-tf-controller/backup-and-restore-a-Terraform-state/
* Try branch-planner https://flux-iac.github.io/tofu-controller/branch-planner/branch-planner-getting-started/
* Write output to secrets https://flux-iac.github.io/tofu-controller/use-tf-controller/provision-resources-obtain-outputs/
* Create multiple Terraform resources and use dependsOn
* Perform healthChecks using outputs https://flux-iac.github.io/tofu-controller/use-tf-controller/provision-Terraform-resources-that-are-required-health-checks/
* Is a custom backend better than Kubernetes Secrets https://flux-iac.github.io/tofu-controller/use-tf-controller/with-a-custom-backend/
* Investigate plan-only mode
* Create a local Kubernetes Secret remote backend and do local plans
* Play with tfclt cli tool https://flux-iac.github.io/tofu-controller/tfctl/

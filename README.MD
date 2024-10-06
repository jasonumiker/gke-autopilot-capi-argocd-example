# Example of using ClusterAPI, Argo CD and Argo Rollouts to manage GKE Autopilot clusters

This git repo is the examples underpinning a series of three blog posts that I have published:
https://medium.com/@jason-umiker/kubernetes-clusterapi-argocd-easy-end-to-end-declarative-gitops-for-platform-teams-0d237504f6a0
https://medium.com/@jason-umiker/argo-cds-app-of-apps-an-efficient-and-easy-way-for-a-platform-team-to-manage-clusters-and-f23877834d89
and
https://medium.com/@jason-umiker/automatic-rollback-of-your-gitops-with-argo-rollouts-04f94baa2d03

## Deploying this example

You have a choice - do you want to run the Cluster API server locally (in my case via the Kubernetes built-in to Docker Desktop on my laptop) or in the cloud. Regardless of which one you choose I still bootstrapped the one running in the cloud with the docker-desktop one on my laptop - so the question is do you just launch that one this way or do you launch all of them.

### Forking the git repo
You want to fork the git repo on GitHub https://github.com/jasonumiker/gke-autopilot-capi-argocd-example. Just go to that and click the Fork button.

Then do a find/replace across all the files in the repo where you replace `https://github.com/jasonumiker` with whatever the location of your repo is. In Visual Studio Code that is under `Edit` then `Replace in Files`.

### Setting up the initial Cluster API in docker-desktop

This assumes you are doing this on either a Windows machine with both Docker Desktop and WSL2 installed or a Mac. It also assumes you have a Google Cloud project you'll be using to deploy/managed come GKE clusters on.

1. Install Docker Desktop - https://www.docker.com/products/docker-desktop/
1. (If on Windows) Install Ubuntu on WSL2 - https://documentation.ubuntu.com/wsl/en/latest/guides/install-ubuntu-wsl2/
1. Install homebrew (if you don't have it already) - https://brew.sh/
1. Run `brew install clusterctl helm k9s kubectl-argo-rollouts kubernetes-cli kustomize`
1. Open the Docker Desktop Dashboard and click on the settings/gear menu
1. Go to Kubernetes on the left and Enable it
1. (If on Windows) Go to Resources then WSL ingegration and enable your WSL distro
1. Click Apply & restart
1. Run `git clone https://github.com/jasonumiker/gke-autopilot-capi-argocd-example.git`
1. Run `cd capi-init`
1. Edit `create-service-account.sh` and put in your GCP_PROJECT id in the environment variable up top. 
1. Run `create-service-account.sh` This not only creates the service account ClusterAPI will use to manage the GKE cluster(s) but puts the credentials for it in ~/capi-sa.json. Treat this file as sensitive.
1. Run `clusterctl-bootstrap.sh`
1. (Optional) Run `k9s` to see this all running. You have to type 0 to see all Namespaces.

Now you'll have a Cluster API set up to manage GKE clusters in the project you specified running on your machine.

### (Optional) if you want to spin up a more permanent Cluster API management server in GCP to then provision dep1-dev

You can set up the a management cluster dedicated to Cluster API by running:

1. `cd` into `gke-autopilot-capi-argocd-example/clusters/capi-manager`
1. Edit `capi-manager-prod.yaml` and replace the project references with your project ID and the location if you don't want it in Sydney
1. Run `kubectl apply -k .`
1. (Optional) Run `k9s` and then select and press Enter/Return twice on the `capg-controller-manager` Pod to see the logs of the cluster provisioning and then `caaph-controller-manager` to see the Helm charts being provisioned onto the new cluster.
    1. NOTE: This is not an Autopilot GKE cluster because Autopilot doesn't seem to allow the approach the controllers use. After being unable to get Cluster API to run on GKE Autopilot I revertd to using standard GKE. I figured it also serves as a good example for using this for non-Autopilot GKE as well.
1. Once the cluster is up and running then you should set it up in your local kubectl by running `gcloud container clusters get-credentials` on it.
1. Then run `clusterctl-bootstrap.sh` but this time against this cluster in GKE just like you did for the one on docker-desktop.
    1. The difference is that this time we also have bootstrapped Argo CD to watch the `cluster-argo-apps/capi-manager-prod` folder for GitOps. So we can point that at other Cluster API manifests via GitOps and it'll provision/update/deprovison any we specify there. By default that is dept1-dev.

### Provisioning dept1-dev from Cluster API in docker-desktop directly

1. `cd` into `gke-autopilot-capi-argocd-example/clusters/dept1`
1. Edit `dept1-dev.yaml` and replace the project references with your project ID and the location if you don't want it in Sydney
1. Run `kubectl apply -k .`
1. (Optional) Run `k9s` and then select and press Enter/Return twice on the `capg-controller-manager` Pod to see the logs of the cluster provisioning and then `caaph-controller-manager` to see the Helm charts being provisioned onto the new cluster.
1. The new cluster will have pulled in any argo apps in `cluster-argo-apps/dept1-dev` with its Argo CD

### Adding dept2-dev

If you deployed the capi-manager-prod into GCP with Argo CD there you would:
1. Edit `cluster-argo-apps/capi-manager-prod/kustomization.yaml` and add the line `- ../../clusters/dept2` under resources.
1. Commit and merge the change and Argo CD will pull dept2-dev in and Cluster API will then deploy that

Or, if you are using docker-desktop direcltly:
1. Run `kubectl apply -k clusters/dept2 --context docker-desktop` in the project's base directory to get it to deploy that cluster as well

## Finishing setup of up the Argo Rollouts Example

Argo Rollouts can't query GCP's Managed Prometheus directly. Instead we need to run their frontend service with a service account that has the rights to as a sort of proxy. This is documented here - https://cloud.google.com/stackdriver/docs/managed-prometheus/query.

There is a script in `app-manifests/gcp-managed-prometheus-frontend` called `setup-service-account.sh` that will help with that.

1. Edit `setup-service-account.sh` with your project ID
1. Run `setup-service-account.sh` to create the service account and give the default service account in the default namespace in EKS access to that

The `dept1-dev` cluster should have already deployed gcp-managed-prometheus-frontend whose service account should now be enabled for the access it needs by that script.

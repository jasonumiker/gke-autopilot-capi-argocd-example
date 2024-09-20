helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argo-cd argo/argo-cd --create-namespace --values argo-helm-values.yaml -n argocd 
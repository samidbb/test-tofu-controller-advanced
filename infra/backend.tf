terraform {
  backend "kubernetes" {
    secret_suffix     = "test"
    in_cluster_config = true
    namespace         = "flux-system"
  }
}

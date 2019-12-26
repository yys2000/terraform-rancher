resource rancher2_namespace radarr {
  name        = "radarr"
  description = "Namespace for radarr app components"
  project_id  = data.rancher2_project.default.id
}

resource kubernetes_persistent_volume radarr {
  count = length(var.radarr_nfs)
  metadata {
    name = values(var.radarr_nfs)[count.index].name
  }
  spec {
    capacity = {
      storage = values(var.radarr_nfs)[count.index].capacity
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = values(var.radarr_nfs)[count.index].nfs_path
      }
    }
  }
}

resource kubernetes_persistent_volume_claim radarr {
  count = length(var.radarr_nfs)
  metadata {
    name      = values(var.radarr_nfs)[count.index].name
    namespace = rancher2_namespace.radarr.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = values(var.radarr_nfs)[count.index].capacity
      }
    }
    volume_name = kubernetes_persistent_volume.radarr[count.index].metadata.0.name
  }
}

data template_file radarr_values {
  template = file("${path.module}/templates/radarr_values.yaml.tpl")
  vars = {
    process_uid   = var.process_uid
    process_gid   = var.process_gid
    hostname      = "${var.radarr_hostname}.${var.dns_domain}"
    pvc_config    = var.radarr_nfs.config.name
    pvc_downloads = var.radarr_nfs.downloads.name
    pvc_movies    = var.radarr_nfs.movies.name
    node_selector = yamlencode(var.vpn_node_selector)
  }
}

resource rancher2_app radarr {
  name             = "radarr"
  catalog_name     = "${data.terraform_remote_state.cluster.outputs.cluster_id}:${rancher2_catalog.custom.name}"
  project_id       = data.rancher2_project.default.id
  target_namespace = rancher2_namespace.radarr.name
  template_name    = "radarr"
  values_yaml      = base64encode(data.template_file.radarr_values.rendered)
}

resource dns_cname_record radarr {
  zone  = "${var.dns_domain}."
  name  = var.radarr_hostname
  cname = var.dns_ingress_a_record
  ttl   = 60
}
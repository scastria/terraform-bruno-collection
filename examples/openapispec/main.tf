terraform {
  required_version = "~> 1.5"
  required_providers {
    bruno = {
      source = "scastria/bruno"
      version = "~> 0.1"
    }
  }
}

provider "bruno" {
  collection_path = "/Users/shawncastrianni/GIT/bruno/example"
}

locals {
  test_scripts = {for f in fileset(path.module, "tests*.js"): regex("tests(?P<path>.*)\\.js", f)["path"] => split("\n", file("${path.module}/${f}"))}
}

module "openapispec" {
  source = "../.."
  collection_name = "Collection"
  openapi_url = "https://httpbin.konghq.com/spec.json"
  url_base = "https://httpbin.konghq.com"
  default_param_values = yamldecode(file("${path.module}/default_params.yml"))
  tests = yamldecode(file("${path.module}/tests.yml"))
  test_scripts = local.test_scripts
  test_group_vars = {
    group1 = {
      client_id = "client_id"
      client_secret = "client_secret"
    }
  }
}

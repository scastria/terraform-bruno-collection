resource "bruno_collection" "Collection" {
  name = var.collection_name
  pre_request_var {
    key = "url_base"
    value = var.url_base
  }
  dynamic "pre_request_var" {
    for_each = var.collection_vars
    iterator = pvar
    content {
      key = pvar.key
      value = pvar.value
    }
  }
  pre_request_script = var.collection_pre_request_script
}
resource "bruno_folder" "CategoryFolder" {
  for_each = toset(local.categories)
  name = each.key
}
resource "bruno_folder" "RequestFolder" {
  for_each = toset(local.folders)
  parent_folder_id = bruno_folder.CategoryFolder[split("--", each.key)[0]].id
  name = split("--", each.key)[1]
}
resource "bruno_folder" "ParentTestFolder" {
  name = var.automated_tests_folder
  tests = lookup(var.test_scripts, "", [])
  pre_request_var {
    key = "is_test"
    value = "true"
  }
}
resource "bruno_folder" "TestStatusFolder" {
  for_each = var.tests
  parent_folder_id = bruno_folder.ParentTestFolder.id
  name = each.key
  tests = lookup(var.test_scripts, "--${split("--", each.key)[0]}", [""])
}
resource "bruno_folder" "TestStatusGroupFolder" {
  for_each = toset(local.test_status_group_folders)
  parent_folder_id = bruno_folder.TestStatusFolder[split("--", each.key)[0]].id
  name = split("--", each.key)[1]
  dynamic "pre_request_var" {
    for_each = lookup(var.test_group_vars, split("--", each.key)[1], {})
    iterator = tvar
    content {
      key = tvar.key
      value = tvar.value
    }
  }
  tests = lookup(var.test_scripts, "--${split("--", each.key)[0]}--${split("--", each.key)[1]}", [""])
}
resource "bruno_folder" "TestRequestFolder" {
  for_each = toset(local.test_request_folders)
  parent_folder_id = bruno_folder.TestStatusGroupFolder["${split("--", each.key)[0]}--${split("--", each.key)[1]}"].id
  name = split("--", each.key)[2]
  tests = lookup(var.test_scripts, "--${split("--", each.key)[0]}--${split("--", each.key)[1]}${replace(split("--", each.key)[2], "/", "--")}", [""])
}
resource "bruno_request" "Request" {
  for_each = toset(local.requests)
  folder_id = bruno_folder.RequestFolder["${split("--", each.key)[0]}--${split("--", each.key)[1]}"].id
  name = split("--", each.key)[2]
  method = split("--", each.key)[2]
  base_url = "{{url_base}}${split("--", each.key)[1]}"
  body = lookup(lookup(lookup(var.default_param_values, split("--", each.key)[1], {}), split("--", each.key)[2], {}), "body", null) == null ? null : split("\n", jsonencode(lookup(lookup(lookup(var.default_param_values, split("--", each.key)[1], {}), split("--", each.key)[2], {}), "body", {})))
  dynamic "query_param" {
    for_each = local.query_params[each.key]
    content {
      key = query_param.value["name"]
      value = lookup(lookup(lookup(lookup(var.default_param_values, split("--", each.key)[1], {}), split("--", each.key)[2], {}), "query_params", {}), query_param.value["name"], "")
      disabled = !lookup(query_param.value, "required", false)
    }
  }
  dynamic "header" {
    for_each = lookup(lookup(lookup(var.default_param_values, split("--", each.key)[1], {}), split("--", each.key)[2], {}), "headers", {})
    content {
      key = header.key
      value = header.value
      disabled = false
    }
  }
}
resource "bruno_request" "TestRequest" {
  for_each = toset(local.test_requests)
  folder_id = bruno_folder.TestRequestFolder["${split("--", each.key)[0]}--${split("--", each.key)[1]}--${split("--", each.key)[2]}"].id
  name = "${split("--", each.key)[3]}-${split("--", each.key)[4]}"
  method = split("--", each.key)[3]
  base_url = "{{url_base}}${split("--", each.key)[2]}"
  body = lookup(var.tests[split("--", each.key)[0]][split("--", each.key)[1]][split("--", each.key)[2]][split("--", each.key)[3]][split("--", each.key)[4]], "body", null) == null ? null : split("\n", jsonencode(lookup(var.tests[split("--", each.key)[0]][split("--", each.key)[1]][split("--", each.key)[2]][split("--", each.key)[3]][split("--", each.key)[4]], "body", null)))
  dynamic "query_param" {
    for_each = toset(flatten([for qp, qpv in lookup(var.tests[split("--", each.key)[0]][split("--", each.key)[1]][split("--", each.key)[2]][split("--", each.key)[3]][split("--", each.key)[4]], "query_params", {}): [
      for i, qv in try([tostring(qpv)], tolist(qpv)): "${qp}--${i}"
    ]]))
    content {
      key = split("--", query_param.key)[0]
      value = try(var.tests[split("--", each.key)[0]][split("--", each.key)[1]][split("--", each.key)[2]][split("--", each.key)[3]][split("--", each.key)[4]]["query_params"][split("--", query_param.key)[0]][split("--", query_param.key)[1]], var.tests[split("--", each.key)[0]][split("--", each.key)[1]][split("--", each.key)[2]][split("--", each.key)[3]][split("--", each.key)[4]]["query_params"][split("--", query_param.key)[0]])
      disabled = false
    }
  }
  dynamic "header" {
    for_each = lookup(var.tests[split("--", each.key)[0]][split("--", each.key)[1]][split("--", each.key)[2]][split("--", each.key)[3]][split("--", each.key)[4]], "headers", {})
    content {
      key = header.key
      value = header.value
      disabled = false
    }
  }
  tests = lookup(var.test_scripts, "--${split("--", each.key)[0]}--${split("--", each.key)[1]}${replace(split("--", each.key)[2], "/", "--")}--${split("--", each.key)[3]}", [""])
}

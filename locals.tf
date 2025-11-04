locals {
  oas = jsondecode(data.http.openapi_spec.response_body)
  paths = [for p, pv in local.oas["paths"] : p if (length(var.path_prefix_include_filter) == 0) || (anytrue([for prefix in var.path_prefix_include_filter: startswith(p, prefix)]))]
  # category
  categories = distinct(flatten([for p in local.paths : [
    for m, mv in local.oas["paths"][p] : ((length(lookup(mv, "tags", [])) > 0) ? mv["tags"][0] : var.uncategorized_api_folder)
  ]]))
  # category--path
  folders = distinct(flatten([for p in local.paths : [
    for m, mv in local.oas["paths"][p] : ((length(lookup(mv, "tags", [])) > 0) ? "${mv["tags"][0]}--${p}" : "${var.uncategorized_api_folder}--${p}")
  ]]))
  # category--path--method
  requests = flatten([for f in local.folders : [
    for m, mv in local.oas["paths"][split("--", f)[1]] : "${f}--${m}" if (length(var.method_exclude_filter) == 0) || (!anytrue([for method in var.method_exclude_filter: (lower(m) == method)]))
  ]])
  query_params = {for r in local.requests : r => [
    for q in lookup(local.oas["paths"][split("--", r)[1]][split("--", r)[2]], "parameters", []) : q if q["in"] == "query"
  ]}
  # status--group
  test_status_group_folders = flatten([for s, sv in var.tests: [
    for g, gv in sv: "${s}--${g}"
  ]])
  # status--group--path
  test_request_folders = flatten([for sg in local.test_status_group_folders: [
    for p, pv in var.tests[split("--", sg)[0]][split("--", sg)[1]]: "${split("--", sg)[0]}--${split("--", sg)[1]}--${p}" if (length(var.path_prefix_include_filter) == 0) || (anytrue([for prefix in var.path_prefix_include_filter: startswith(p, prefix)]))
  ]])
  # status--group--path--method--index
  test_requests = flatten([for sgp in local.test_request_folders: [
    for m, mv in var.tests[split("--", sgp)[0]][split("--", sgp)[1]][split("--", sgp)[2]]: [
      for i, t in mv: "${split("--", sgp)[0]}--${split("--", sgp)[1]}--${split("--", sgp)[2]}--${m}--${i}"
  ]]])
}

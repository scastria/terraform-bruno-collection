variable "openapi_url" {
  type = string
  description = "The URL of the OpenAPI spec to import"
}
variable "collection_name" {
  type = string
  description = "The name of the Bruno collection to create"
}
variable "collection_vars" {
  type = map(string)
  description = "Extra variables to set on the Bruno collection"
  default = {}
}
variable "collection_pre_request_script" {
  type = list(string)
  description = "The pre-request script to be attached to the Bruno collection"
  default = [""]
}
variable "url_base" {
  type = string
  description = "The base URL to use for all requests in the Bruno collection"
}
variable "path_prefix_include_filter" {
  type = set(string)
  description = "A list of prefixes to filter paths by.  Matching prefix will INCLUDE the path.  Empty set means no filtering"
  default = []
}
variable "method_exclude_filter" {
  type = set(string)
  description = "A list of LOWERCASE HTTP methods to filter requests by.  Matching method will EXCLUDE the request.  Empty set means no filtering"
  default = ["trace"]
}
variable "automated_tests_folder" {
  type = string
  description = "The name of the folder to put automated tests in"
  default = "tests"
}
variable "uncategorized_api_folder" {
  type = string
  description = "The name of the folder to put uncategorized endpoints in"
  default = "Uncategorized APIs"
}
variable "default_param_values" {
  type = any
  description = "Default parameter values to use for requests.  The first key is the path, the second key is the method, then either query_params or headers, and the third key is the parameter or header name"
  default = {}
}
variable "test_scripts" {
  type = map(list(string))
  description = "Test scripts to run for automated tests.  These are attached to the matching folder or request.  The key is location within tests, and the value is the script"
  default = {}
}
variable "tests" {
  type = any
  description = "Test requests to create in the automated tests folder.  The first key is the status code, the second key is the group name, the third key is the path, the fourth key is the method, then a list of maps of parameter names with values. This allows the same request to be tested more than once with different input parameter sets."
  default = {}
}

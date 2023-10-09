terraform {
  source = "../../../modules/data"
}

include "root" {
  path = find_in_parent_folders()
}
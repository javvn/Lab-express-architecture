output "context" {
  value = local.context
}

output "common_tags" {
  value = local.common_tags
}

output "network" {
  value = {
    vpc = { for k, v in module.vpc : k => v if contains(local.vpc_search_set, k) }
    igw = { for k, v in module.vpc : k => v if contains(local.igw_search_set, k) }
    route_table = {
      public  = { for k, v in module.vpc : k => v if contains(local.public_rt_search_set, k) }
      private = { for k, v in module.vpc : k => v if contains(local.private_rt_search_set, k) }
    }
    subnet_groups = {
      public  = { for k, v in module.vpc : k => v if contains(local.public_subnet_search_set, k) }
      private = { for k, v in module.vpc : k => v if contains(local.private_subnet_search_set, k) }
    }
    security_groups = module.sg
  }
}
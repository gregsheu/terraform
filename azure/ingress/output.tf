output "prometheus_apply" {
  value = "${terraform_data.prometheus_addon.output}"
}

output "restart_nginx" {
  value = "${terraform_data.restart.output}"
}

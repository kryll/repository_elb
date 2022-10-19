# Ejemplos de terraform

## Guía de pasos
- cp .env.examples .env
- cp terraform.tfvars.example a terraform.tfvars
- Modificar .env
- Modificar terraform.tfvars
source .env
terraform init
terraform plan
terraform apply

## Eliminar recursos
- terraform destroy
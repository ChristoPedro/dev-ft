
# Create a Vault
resource "oci_kms_vault" "ft_vault" {
  compartment_id = var.compartment_id
  display_name   = var.vault_display_name
  vault_type     = "DEFAULT"
}

# Create a Key for encryption
resource "oci_kms_key" "ft_key" {
  compartment_id      = var.compartment_id
  display_name        = "dbkey"
  management_endpoint = oci_kms_vault.ft_vault.management_endpoint
  key_shape {
    algorithm = "AES"
    length    = 32
  }
}

# Generate a random password
resource "random_password" "db_password" {
  length  = 16
  special = true
  numeric = true
}

# Store the password as a Vault Secret
resource "oci_vault_secret" "ft_secret" {
  compartment_id = var.compartment_id
  vault_id       = oci_kms_vault.ft_vault.id
  key_id         = oci_kms_key.ft_key.id
  secret_name    = "AutonomousJson"
  secret_content {
    content_type = "BASE64"
    content      = base64encode(random_password.db_password.result)
  }
}

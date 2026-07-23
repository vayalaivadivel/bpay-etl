resource "local_file" "init_databases" {
  content = templatefile("${path.module}/init-databases.sql.tpl", {
    db_name            = var.db_name
    raw_db_name        = var.raw_db_name
    replicated_db_name = var.replicated_db_name
    unified_db_name    = var.unified_db_name
  })

  filename = "${path.root}/.terraform-rendered/ec2/init-databases.sql"
}

resource "local_file" "init_source" {
  content = templatefile("${path.module}/init-source.sql.tpl", {
    db_name = var.db_name
  })

  filename = "${path.root}/.terraform-rendered/ec2/init-source.sql"
}

resource "local_file" "init_replicated" {
  content = templatefile("${path.module}/init-replicated.sql.tpl", {
    replicated_db_name = var.replicated_db_name
  })

  filename = "${path.root}/.terraform-rendered/ec2/init-replicated.sql"
}

resource "local_file" "init_unified" {
  content = templatefile("${path.module}/init-unified.sql.tpl", {
    unified_db_name = var.unified_db_name
  })

  filename = "${path.root}/.terraform-rendered/ec2/init-unified.sql"
}
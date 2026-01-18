output "first_email" {
  # Convert to list and get index 0
  value       = element(values(google_project_iam_member.example)[*].member, 0)
  description = "The first email in the list"
}

output "all_emails" {
  value       = [for m in google_project_iam_member.example : m.member]
  description = "All group emails"
}

output "upper_emails" {
  value       = [for default in var.usernames : upper(default)]
  description = "All group emails in uppercase"
}

output "bios" {
    value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

output "upper_roles" {
  value = {for name, role in var.hero_thousand_faces : upper(name) => upper(role)}
}

output "for_directive" {
    value = "%{ for name in var.names }${name}, %{ endfor }"
}

output "for_directive_index" {
    value = "%{ for i, name in var.names }(${i}) ${name} %{ endfor }"
}

output "for_directive_index_if_strip" {
    value = <<EOF
%{~ for i, name in var.names ~}
${name}%{ if i < length(var.names) - 1 }, %{else }.%{ endif }
%{~ endfor ~}
EOF
}
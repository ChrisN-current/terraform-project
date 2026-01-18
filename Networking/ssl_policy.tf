resource "google_compute_ssl_policy" "current-modern-global-ssl-policy" {
  name            = "current-modern-global-ssl-policy"
  description     = "TLS 1.2+ and modern ciphers (may contain weak ciphers)"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_ssl_policy" "current-secure-global-ssl-policy" {
  name            = "current-secure-global-ssl-policy"
  description     = "TLS 1.2+ and only secure ciphers"
  profile         = "RESTRICTED"
  min_tls_version = "TLS_1_2"
}


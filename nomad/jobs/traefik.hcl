job "traefik" {
	datacenters = ["dc1"]
	type        = "service"
	constraint {
		attribute = "${attr.unique.hostname}"
		operator = "set_contains_any"
		value = "klaus,turing"
	}
	spread {
		attribute = "${node.unique.name}"
		weight = 50 
	}
	group "traefik" {
		count = 2

		network {
			port  "http"{
				static = 80
				host_network = "default"
			}
			port "https" {
				static = 443
				host_network = "default"
			}
			port  "admin" {
				static = 8080
				host_network = "ts"
			}
		}

	service {
		name = "traefik-http"
		provider = "consul"
		port = "http"
	}

		task "server" {
			driver = "docker"
			config {
				image = "docker.io/traefik:v3.0"
				ports = ["admin", "http", "https"]
				args = [
					"--global.sendanonymoususage=false",
					"--api.dashboard=true",
					"--api.insecure=true",
					"--entrypoints.web.address=:${NOMAD_PORT_http}",
					"--entrypoints.websecure.address=:${NOMAD_PORT_https}",
					"--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
					"--providers.consulCatalog=true",
					"--providers.consulCatalog.endpoint.address=127.0.0.1:8500",
					"--providers.consulCatalog.endpoint.scheme=https",
					"--providers.consulCatalog.connectAware=true",
					"--providers.consulCatalog.prefix=traefik",
					"--providers.consulCatalog.exposedByDefault=false",
					"--certificatesresolvers.cheap.acme.storage=/acme.json",
					"--certificatesresolvers.cheap.acme.httpchallenge=true",
					"--certificatesresolvers.cheap.acme.httpchallenge.entrypoint=web",
					"--certificatesresolvers.cheap.acme.email=paul@alcock.dev",
				]
			}
		}
	}
}

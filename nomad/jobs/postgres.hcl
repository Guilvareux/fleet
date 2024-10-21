job "postgres" {
	datacenters = ["dc1"]
	type = "service"
	constraint {
		attribute = "${attr.unique.hostname}"
		value = "klaus"
	}
	group "postgres" {
		count = 1

		network {
			port "http" {
				to = 8080
				host_network = "default"
			}
		}

		volume "postgres" {
			type = "host"
			read_only = false
			source = "postgres"
		}

		service {
			name = "postgres"
			provider = "consul"
			port = "http"

			tags = [
				"traefik.http.routers.postgres.entryPoints=web",
				"traefik.http.services.postgres.loadbalancer.server.port=${NOMAD_HOST_PORT_http}",
				"traefik.http.routers.postgres.rule=Host(`postgres.wyeaye.com`) || Path(`/postgres`)",
			]
		}

		task "server" {
			driver = "docker"
			env {
				POSTGRES_PASSWORD = "4d7b8e262e89c8c9d863"
			}
			volume_mount {
				volume = "postgres"
				destination = "/var/lib/postgresql/data"
				read_only = false
			}
			config {
				image = "docker.io/postgres"
				ports = ["http"]
			}
		}
	}
}

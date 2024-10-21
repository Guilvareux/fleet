job "mongodb" {
	datacenters = ["dc1"]
	type = "service"
	constraint {
		attribute = "${attr.unique.hostname}"
		value = "klaus"
	}
	meta {
		class = "oracle"
	}
	group "mongodb" {
		count = 1

		network {
			port "http" {
				to = 27017
				host_network = "ts"
			}
		}

		service {
			name = "mongodb"
			provider = "nomad"
			port = "http"

			tags = [
				"traefik.enable=false"
			]
		}

		task "server" {
			driver = "docker"
			env {
				MONGO_INITDB_ROOT_USERNAME = "root"
				MONGO_INITDB_ROOT_PASSWORD = "4d7b8e262e"
			}
			config {
				image = "docker.io/mongo"
				ports = ["http"]
			}
		}
	}
}

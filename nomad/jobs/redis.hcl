job "redis" {
	datacenters = ["dc1"]
	type = "service"
	affinity {
		attribute = "${attr.unique.hostname}"
		value = "klaus"
		weight = 100
	}
	meta {
		class = "oracle"
	}
	group "redis" {
		count = 1

		network {
			port "http" {
				to = 6379
				host_network = "default"
			}
		}

		service {
			name = "redis"
			provider = "consul"
			port = "http"

			tags = [
				"traefik.enable=false"
			]
			check {
				name = "redis_probe"
				type = "tcp"
				interval = "30s"
				timeout = "1s"
			}
		}

		task "server" {
			driver = "docker"
			config {
				image = "docker.io/redis:7-alpine"
				ports = ["http"]
			}
		}
	}
}

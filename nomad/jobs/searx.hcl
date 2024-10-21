job "searx" {
	datacenters = ["dc1"]
	type = "service"
	group "searx" {
		count = 1

		network {
			port "http" {
				to = 8080
				host_network = "ts"
			}
		}

		service {
			name = "searx"
			provider = "nomad"
			port = "http"

			tags = [
				"traefik.http.routers.searx.entryPoints=web,websecure",
				"traefik.http.services.searx.loadbalancer.server.port=${NOMAD_HOST_PORT_http}",
				"traefik.http.routers.searx.rule=Host(`searx.wyeaye.com`) || Path(`/searx`)",
			]
		}

		task "server" {
			driver = "docker"
			config {
				image = "docker.io/searxng/searxng"
				ports = ["http"]
			}
		}
	}
}

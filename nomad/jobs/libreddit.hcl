job "libreddit" {
	datacenters = ["dc1"]
	type = "service"
	constraint {
		attribute = "${node.class}"
		value = "oracle"
	}
 	group "libreddit" {
		count = 1

		network {
			port "http" {
				to = 8080
				host_network = "default"
			}
		}

		service {
			name = "libreddit"
			provider = "nomad"
			port = "http"

			tags = [
				"traefik.http.routers.libreddit.entryPoints=websecure",
				"traefik.http.services.libreddit.loadbalancer.server.port=${NOMAD_HOST_PORT_http}",
				"traefik.http.routers.libreddit.rule=Host(`libreddit.wyeaye.com`) || Path(`/libreddit`)",
			]
		}

		task "server" {
			driver = "docker"
			env {
				LIBREDDIT_DEFAULT_THEME = "dark"
				LIBREDDIT_DEFAULT_USE_HLS = "on"
				LIBREDDIT_DEFAULT_SHOW_NSFW = "on"
			}
			config {
				image = "docker.io/spikecodes/libreddit"
				ports = ["http"]
				command = "libreddit"
			}
		}
	}
}

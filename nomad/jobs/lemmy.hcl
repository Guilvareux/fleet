job "lemmy" {
	datacenters = ["dc1"]
	type = "service"
	group "lemmy" {
		count = 1

		network {
			port "lemmy" {
				to = 8536
				host_network = "public"
			}
			port "lemmy-ui" {
				to = 1234
				host_network = "public"
			}
		}

		service {
			name = "lemmy"
			provider = "nomad"
			port = "http"

			tags = [
				"traefik.http.routers.lemmy.entryPoints=web,websecure",
				"traefik.http.services.lemmy.loadbalancer.server.port=${NOMAD_HOST_PORT_http}",
				"traefik.http.routers.lemmy.rule=Host(`lemmy.wyeaye.com`) || Path(`/lemmy`)",
			]
		}

		task "lemmy" {
			driver = "docker"
			config {
				image = "docker.io/dessalines/lemmy"
				ports = ["http"]
			}
		}

		task "lemmy-ui" {
			driver = "docker"
			config {
				image = "docker.io/dessalines/lemmy"
				ports = ["http"]
			}
		}
		
		task "pictrs" {
			driver = "docker"
			config {
				image = "docker.io/asonix/pictrs:0.4.0-beta.19"
				ports = 
			}
		}
	}
}

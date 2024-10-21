job "jenkins" {
	datacenters = ["dc1"]
	type = "service"
	constraint {
		attribute = "${attr.unique.hostname}"
		value = "klaus"
	}
	group "jenkins" {
		count = 1

		network {
			mode = "bridge"
			port "http" {
				to = 8080
				host_network = "ts"
			}
			port "other" {
				to = 5000
				host_network = "ts"
			}
		}

		volume "jenkins" {
			type = "host"
			read_only = false
			source = "jenkins"
		}

		service {
			name = "jenkins"
			provider = "consul"
			port = "http"

			tags = [
				"traefik.http.routers.jenkins.entryPoints=web",
				"traefik.http.services.jenkins.loadbalancer.server.port=${NOMAD_HOST_PORT_http}",
				"traefik.http.routers.jenkins.rule=Host(`jenkins.wyeaye.com`) || Path(`/jenkins`)",
			]

			connect {
				sidecar_service {}
			}
		}

		task "server" {
			driver = "docker"
			user = "1002"
			env {
				POSTGRES_PASSWORD = "4d7b8e262e89c8c9d863"
			}
			volume_mount {
				volume = "jenkins"
				destination = "/var/jenkins_home"
				read_only = false
			}
			config {
				image = "docker.io/jenkins/jenkins"
				ports = ["http", "other"]
				privileged = true
			}
		}
	}
}

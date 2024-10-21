job "mastodon" {
	datacenters = ["dc1"]
	type = "service"
	constraint {
		attribute = "${node.class}"
		value = "oracle"
	}
	group "mastodon" {
		count = 1
		meta {
			domain="wyeaye.com"
			dbuser="mastodon"
			dbname="mastodon"
			dbpass="4d7b8e262e89c8c9d863"
			otp="7ba17f33b753cecf2c4d5be9d663761e9f1b9f7e47106ca3556ed088b41a4538d5546a989c750d703f508c09555ed5245e9973f8756e70883cec06fef115198c"
			secret="6f528ef59ed56c5000ada91cdbfe66e45c017c5e7785ea39df37890b862d6c043969e6ed23bdd9f96cde5a65ee6ee5fd7b2368282d5f8e51a11ec46b926c778e"
		}

		network {
			port "web" {
				to = 3000
				host_network = "default"
			}
			port "stream" {
				to = 4000
				host_network = "default"
			}
		}

		volume "mastodon" {
			type = "host"
			read_only = false
			source = "mastodon"
		}

		service {
			name = "mastodon-web"
			provider = "consul"
			port = "web"

			tags = [
				"traefik.http.routers.mastodon.entryPoints=web,websecure",
				"traefik.http.services.mastodon.loadbalancer.server.port=${NOMAD_HOST_PORT_web}",
				"traefik.http.routers.mastodon.rule=Host(`mastodon.wyeaye.com`) || Path(`/mastodon`)",
			]
		}

		service {
			name = "mastodon-stream"
			provider = "consul"
			port = "stream"
			tags = [
				"traefik.http.routers.mastodon.entryPoints=web,websecure",
				"traefik.http.services.mastodon.loadbalancer.server.port=${NOMAD_HOST_PORT_stream}",
				"traefik.http.routers.mastodon.rule=Host(`mastodon.wyeaye.com`) || Path(`/mastodon`)",
			]
		}

		task "web" {
			driver = "docker"
			volume_mount {
				volume = "mastodon"
				destination = "/mastodon/public/system"
				read_only = false
			}
			config {
				image = "ghcr.io/mastodon/mastodon" 
				ports = ["web"] 
				command = "/bin/bash"
				args = [
					"-c", 
					#"'rm -f /mastodon/tmp/pids/server.pid ; bundle exec rails s -p $REDIS_PORT'"
					"bundle exec rails s -p $REDIS_PORT"
				]
			}
			template {
				data = <<EOH
				{{ range service "redis" }}
				REDIS_HOST={{ .Address }}
				REDIS_PORT={{ .Port }}
				{{ end }}
				LOCAL_DOMAIN={{ env "NOMAD_META_domain" }}
				DB_USER={{ env "NOMAD_META_dbuser" }}
				DB_NAME={{ env "NOMAD_META_dbname" }}
				DB_PASS={{ env "NOMAD_META_dbpass" }}
				OTP_SECRET={{ env "NOMAD_META_otp" }}
				SECRET_KEY_BASE={{ env "NOMAD_META_secret" }}
				{{ range service "postgres" }}
				DB_HOST={{ .Address }}
				DB_PORT={{ .Port }}
				{{ end }}
				EOH

				destination = "secrets/config.env"
				env = true
			}
		}

		task "streaming" {
			driver = "docker"
			config {
				image = "ghcr.io/mastodon/mastodon"
				ports = ["stream"]
				command = "node"
				args = [
					"./streaming"
				]
			}
			template {
				data = <<EOH
				{{ range service "redis" }}
				REDIS_HOST={{ .Address }}
				REDIS_PORT={{ .Port }}
				{{ end }}
				LOCAL_DOMAIN={{ env "NOMAD_META_domain" }}
				DB_USER={{ env "NOMAD_META_dbuser" }}
				DB_NAME={{ env "NOMAD_META_dbname" }}
				DB_PASS={{ env "NOMAD_META_dbpass" }}
				OTP_SECRET={{ env "NOMAD_META_otp" }}
				SECRET_KEY_BASE={{ env "NOMAD_META_secret" }}
				{{ range service "postgres" }}
				DB_HOST={{ .Address }}
				DB_PORT={{ .Port }}
				{{ end }}
				EOH

				destination = "secrets/config.env"
				env = true
			}
		}

		task "sidekiq" {
			driver = "docker"
			volume_mount {
				volume = "mastodon"
				destination = "/mastodon/public/system"
				read_only = false
			}
			config {
				image = "ghcr.io/mastodon/mastodon"
				command = "bundle"
				args = [
					"exec", "sidekiq"
				]
			}
			template {
				data = <<EOH
				{{ range service "redis" }}
				REDIS_HOST={{ .Address }}
				REDIS_PORT={{ .Port }}
				{{ end }}
				LOCAL_DOMAIN={{ env "NOMAD_META_domain" }}
				DB_USER={{ env "NOMAD_META_dbuser" }}
				DB_NAME={{ env "NOMAD_META_dbname" }}
				DB_PASS={{ env "NOMAD_META_dbpass" }}
				OTP_SECRET={{ env "NOMAD_META_otp" }}
				SECRET_KEY_BASE={{ env "NOMAD_META_secret" }}
				{{ range service "postgres" }}
				DB_HOST={{ .Address }}
				DB_PORT={{ .Port }}
				{{ end }}
				EOH

				destination = "secrets/config.env"
				env = true
			}
		}
	}
}

version: "3.8"

networks:
  glpi_network:
    driver: bridge

volumes:
  mariadb_data:
  postgres_data:
  glpi_files:
  grafana_data:
  prometheus_data:

services:

  mariadb:
    image: mariadb:10.11
    container_name: mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE:      ${MYSQL_DATABASE}
      MYSQL_USER:          ${MYSQL_USER}
      MYSQL_PASSWORD:      ${MYSQL_PASSWORD}
    volumes:
      - mariadb_data:/var/lib/mysql
      - ./mariadb/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - glpi_network
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 15s
      timeout: 10s
      retries: 10
      start_period: 30s

  postgres:
    image: postgres:15
    container_name: postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB:       ${POSTGRES_DB}
      POSTGRES_USER:     ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - glpi_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 20s

  glpi:
    image: diouxx/glpi
    container_name: glpi
    restart: unless-stopped
    depends_on:
      mariadb:
        condition: service_healthy
    environment:
      MARIADB_HOST:     mariadb
      MARIADB_PORT:     3306
      MARIADB_DATABASE: ${MYSQL_DATABASE}
      MARIADB_USER:     ${MYSQL_USER}
      MARIADB_PASSWORD: ${MYSQL_PASSWORD}
      GLPI_LANG:        fr_FR
      TIMEZONE:         Africa/Ouagadougou
    ports:
      - "8080:80"
    volumes:
      - glpi_files:/var/www/html/files
    networks:
      - glpi_network

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: unless-stopped
    privileged: true
    ports:
      - "8081:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    networks:
      - glpi_network

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    depends_on:
      - cadvisor
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--storage.tsdb.retention.time=${PROMETHEUS_RETENTION}"
    networks:
      - glpi_network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    depends_on:
      - prometheus
      - mariadb
    environment:
      GF_SECURITY_ADMIN_USER:     ${GF_SECURITY_ADMIN_USER}
      GF_SECURITY_ADMIN_PASSWORD: ${GF_SECURITY_ADMIN_PASSWORD}
      GF_INSTALL_PLUGINS:         grafana-piechart-panel
      MYSQL_DATABASE:             ${MYSQL_DATABASE}
      MYSQL_USER:                 ${MYSQL_USER}
      MYSQL_PASSWORD:             ${MYSQL_PASSWORD}
      POSTGRES_DB:                ${POSTGRES_DB}
      POSTGRES_USER:              ${POSTGRES_USER}
      POSTGRES_PASSWORD:          ${POSTGRES_PASSWORD}
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    networks:
      - glpi_network
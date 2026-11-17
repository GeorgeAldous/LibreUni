FROM node:26.7.0-trixie-slim AS builder

WORKDIR /app

# Install the full build-time diagram toolchain, mirroring
# .github/workflows/quality.yml: Python + scientific libraries for
# PythonDiagram, graphviz, TeX Live + dvisvgm + ghostscript for TikZ
# (latex/dvisvgm are invoked by src/components/TikZ.astro), and a
# Java 21 JRE for PlantUML (invoked as `java -jar tools/plantuml.jar`
# by src/components/PlantUML.astro). The trixie base is required
# because openjdk-21 is not available in the bookworm apt archives.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-matplotlib \
    python3-numpy \
    python3-pandas \
    graphviz \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-pictures \
    texlive-fonts-recommended \
    dvisvgm \
    ghostscript \
    openjdk-21-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY package*.json ./
RUN npm ci

# Install Playwright Chromium for CI
RUN npx playwright install --with-deps chromium

# Build the static site
COPY . .

# Fetch the pinned PlantUML jar (verified by SHA-256 in the script)
# before building, exactly as CI does — diagram rendering fails
# without it in a clean checkout.
RUN node tools/download-plantuml.mjs

RUN npm run build:all

FROM nginx:alpine AS runner

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD wget -qO- http://127.0.0.1/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]

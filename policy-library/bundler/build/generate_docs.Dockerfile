FROM node:10-alpine as builder

RUN mkdir -p /home/node/app && \
    chown -R node:node /home/node/app

# Run as non-root user as a best-practices:
# https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md
USER node

WORKDIR /home/node/app

# Install dependencies and cache them.
COPY --chown=node:node package*.json ./
RUN npm ci

# Build the source.
COPY --chown=node:node tsconfig.json .
COPY --chown=node:node src src
RUN npm run build && \
    npm prune --production && \
    rm -r src tsconfig.json

#############################################

FROM node:10-alpine

USER root

WORKDIR /home/node/app

COPY --from=builder /home/node/app /home/node/app

ENTRYPOINT ["node", "/home/node/app/dist/generate_docs_run.js"]

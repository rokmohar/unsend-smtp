####################
FROM node:20-alpine AS base

WORKDIR /app

RUN apk update && apk upgrade
RUN apk add --no-cache bash git openssh

####################
FROM base AS cloner

RUN git clone https://github.com/unsend-dev/unsend.git .

####################
FROM base AS builder

COPY --from=cloner /app/apps/smtp-server .

RUN yarn install --preffer-offline --non-interactive

RUN yarn build

####################
FROM base AS runner

COPY --from=builder /app/package.json .
COPY --from=builder /app/dist ./dist

RUN yarn install --preffer-offline --non-interactive --production

ENTRYPOINT ["yarn", "start"]

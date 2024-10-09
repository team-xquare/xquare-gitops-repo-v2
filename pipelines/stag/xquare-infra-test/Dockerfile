
FROM node:22.5.1-alpine AS builder

RUN apk add --no-cache libc6-compat

COPY . .


RUN yarn install && yarn build




FROM nginx:alpine AS runner

RUN echo "\
server {\
listen 3000;\
location / {\
root   /usr/share/nginx/html;\
index  index.html index.html;\
try_files \$uri \$uri/ /index.html =404;\
}\
}" > /etc/nginx/conf.d/default.conf

COPY --from=builder / /usr/share/nginx/html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]


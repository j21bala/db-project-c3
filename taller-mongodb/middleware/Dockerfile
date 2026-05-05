FROM node:20-alpine
WORKDIR /workspace
RUN apk add --no-cache bash curl
COPY package*.json ./
RUN npm install
EXPOSE 3000
CMD ["node", "middleware/src/index.js"]
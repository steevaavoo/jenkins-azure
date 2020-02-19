# Build stage
FROM node:8 as build
WORKDIR /app
COPY package*.json server.js ./
RUN npm ci --only=production

# Final stage
FROM gcr.io/distroless/nodejs
COPY --from=build /app /
EXPOSE 80
CMD ["server.js"]

FROM node:current-alpine

# Update npm to latest version (not mandatory)
RUN npm install -g npm

# Add App to the container
ADD nodejs-code/app.js /git/nodejs-test/nodejs-code/

# Set workdir
WORKDIR /git/nodejs-test/nodejs-code

# Build code with express-genrator (alternative, just run with node app.js)
#RUN npx express-generator --view=pug --force nodejs-built

# Set workdir to the built code
#WORKDIR /git/nodejs-test/nodejs-code/nodejs-built

# Install new module
#RUN npm install

# Run the code with console Debug mode.
#  Console Debug mode is  optional.
#ENV DEBUG nodejs-test:*
#ENTRYPOINT npm start
ENTRYPOINT node app.js

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:3000/ || exit 1
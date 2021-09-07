FROM node:current-alpine

WORKDIR /git/nodejs-test/nodejs-code

RUN npx express-generator --view=jade --force

RUN npm install

CMD ["DEBUG=nodejs-test:* npm start"]
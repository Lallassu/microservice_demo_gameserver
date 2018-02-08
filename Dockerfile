FROM node:alpine

# Create app directory
RUN mkdir -p /badsanta/
WORKDIR /badsanta

# Bundle app source
ADD dist /badsanta
RUN npm install --production 

EXPOSE 8000
CMD [ "npm", "start" ]

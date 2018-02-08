FROM node:alpine

# Create app directory
RUN mkdir -p /badsanta/
WORKDIR /badsanta

# Install app dependencies
RUN npm install --production 
# grunt dist

# Bundle app source
ADD dist /badsanta

EXPOSE 8000
CMD [ "npm", "start" ]

# README

Rails boiler plate api for an shop application.
Using Mobility for translations and auth0 for authentication.

## Auth0 initialization

1. Create a new API:
   - Define an identifier which will the audience (ex: `http://boiler-plate-api.com`)
     
2. Create an application as a Regular Web Application:
   - Define allowed callback (ex: `http://localhost:3000/api/auth/callback`)
   - Define allowed logout (ex: `http://localhost:3000`) urls
     
3. Create Roles (ex: `admin, manager, client`)
   
4. Create Actions:
   - **Post login action:**
     
     _We need to add roles to the idToken (for frontend) to manage access to pages and to the accessToken (for backend) to manage api calls permissions_

     - Replace the path with the audience you defined for the api (ex: `http://boiler-plate-api.com/roles`)
   
      ```
       exports.onExecutePostLogin = async (event, api) => {
          const assignedRoles = event.authorization?.roles ?? [];
          api.idToken.setCustomClaim([AUDIENCE]/roles, assignedRoles);
          api.accessToken.setCustomClaim([AUDIENCE]/roles, assignedRoles);
        };
      ```
   - **Post User Registration:**
     
     _We need to trigger a call to create a user in the db with the freshly created auth0 user_
     
     - Create a secret key to be added to the authorization
     - Replace [DOMAIN] with an ngrok endpoint in local
  
       
     ```
     const axios = require("axios");
      exports.onExecutePostUserRegistration = async (event) => {
        await axios.post("[DOMAIN]/users", 
          { params: { user: event.user } },
          { headers: { Authorization: `Bearer ${event.secrets.WEBHOOK_TOKEN}`} }
        );
      };
      ```

## Create an env.local file

```
AUTH0_ISSUER=<AUTH0_ISSUER> Can be found in quick start of the auth0 api
AUTH0_WEBHOOK_TOKEN=<AUTH0_WEBHOOK_TOKEN> The one we set for the Post User Registration in auth0
API_AUDIENCE=<API_AUDIENCE> The one we set at api creation in auth0
CORS_ORIGIN=<CORS_ORIGIN> Allowed domain to call the api 
```


  

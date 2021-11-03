# Installation

## Init your project
```bash
npm init -y
```
### If you use yarn 
```bash
yarn init -y
```
## Install dependencies
### If you use npm
```bash
npm install --save-dev doba-template
```
### If you use yarn 
```bash
yarn add -D doba-template
```

# Usage

### Run this command
```bash
npx doba-template
```

# GraphQL template
```bash
.env.example
.gitignore
.prettierrc
package.json        
src
   |-- Configs      
   |   |-- Logger.ts
   |-- Constants    
   |   |-- index.ts 
   |-- Entities
   |   |-- User.ts
   |-- Middlewares
   |-- Models
   |-- Resolvers
   |   |-- Auth.ts
   |   |-- Hello.ts
   |-- Types
   |   |-- Context.ts
   |   |-- FieldError.ts
   |   |-- InputType
   |   |   |-- RegisterInput.ts
   |   |-- Mutation
   |   |   |-- MutationResponse.ts
   |   |   |-- UserMutationResponse.ts
   |-- Utils
   |   |-- Validation.ts
   |-- index.ts
tsconfig.json
yarn.lock
```

# ExpressJS template
```bash
.env.example
.gitignore
.prettierrc
package.json
src
   |-- Configs
   |   |-- Logger.ts
   |   |-- mongoose.ts
   |-- Constants
   |-- Controllers
   |-- Middlewares
   |-- Models
   |-- Routes
   |   |-- index.routes.ts
   |-- Services
   |-- Utils
   |-- index.ts
tsconfig.json
yarn.lock
```
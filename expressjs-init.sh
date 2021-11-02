
git init

yarn add express cors body-parser mongoose chalk dotenv

yarn add -D ts-node nodemon typescript @types/node @types/express @types/body-parser @types/cors

sed -i '5 i\"scripts": {"start": "node ./build/index.js", "dev": "nodemon ./src/index.ts", "build": "rm -rf ./build && tsc"},' ./package.json

mkdir src

touch .env .env.example .gitignore

echo "PORT = your_port
MONGODB_URL = your_mongodb_url" >> .env.example

echo "PORT = $1
MONGODB_URL = $2" >> .env

echo "/node_modules
/build
/.env" >> .gitignore

echo "{
  \"arrowParens\": \"always\",
  \"bracketSameLine\": false,
  \"bracketSpacing\": true,
  \"embeddedLanguageFormatting\": \"auto\",
  \"htmlWhitespaceSensitivity\": \"css\",
  \"insertPragma\": false,
  \"jsxSingleQuote\": false,
  \"printWidth\": 100,
  \"proseWrap\": \"preserve\",
  \"quoteProps\": \"as-needed\",
  \"requirePragma\": false,
  \"semi\": true,
  \"singleQuote\": true,
  \"tabWidth\": 4,
  \"trailingComma\": \"es5\",
  \"useTabs\": false,
  \"vueIndentScriptAndStyle\": false
}" >> .prettierrc

echo "{
  \"compilerOptions\": {
    \"target\": \"ES2020\",
    \"experimentalDecorators\": true,
    \"emitDecoratorMetadata\": true,
    \"module\": \"commonjs\",
    \"rootDir\": \"./src\",
    \"outDir\": \"./build\",
    \"esModuleInterop\": true,
    \"forceConsistentCasingInFileNames\": true,
    \"strict\": true,
    \"strictPropertyInitialization\": false,
    \"skipLibCheck\": true
  }
}" >> tsconfig.json

cd src

mkdir Controllers Routes Configs Models Middlewares Constants Services Utils

touch index.ts

echo "require('dotenv').config();
import express from 'express';
import router from './Routes/index.routes';
import cors from 'cors';
import bodyParser from 'body-parser';
import Logger from './Configs/Logger';
import connectDB from './Configs/mongoose'

const app = express();
const PORT = process.env.PORT || 4000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cors());
connectDB();

router(app);

app.listen(PORT, () => {
    Logger.success(\`Server is running on: http://localhost:\${PORT}\`);
});" >> index.ts

cd Configs

touch Logger.ts mongoose.ts

echo "import chalk from 'chalk';

export default class Logger {
    public static success(content: any): void {
        console.log(chalk.bgGreen.black(content));
    }
    public static error(content: any): void {
        console.log(chalk.bgRed.black(content));
    }
}" >> Logger.ts

echo "import mongoose from 'mongoose'
import Logger from './Logger'

const connectDB = () => {
    mongoose.connect(process.env.MONGODB_URL as string)
        .then(() => {
            Logger.success('Connect MongoDB successfully');
        }).catch((err: any) => Logger.error(err.message))
}

export default connectDB" >> mongoose.ts

cd ../Routes

touch index.routes.ts

echo " import { Express, Response, Request } from 'express';

const router = (app: Express) => {
    app.get('/', (req: Request, res: Response) => {
        res.json({
            message: 'Hello world'
        })
    });
}

export default router;" >> index.routes.ts

git add --all

git commit -m "First Commit"
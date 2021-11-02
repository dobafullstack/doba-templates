git init

yarn init -y

yarn add express apollo-server-express apollo-server-core chalk class-validator dotenv express-session graphql@15.7.2 lodash md5 mongoose pg reflect-metadata type-graphql typeorm connect-mongo

yarn add -D lodash @types/express-session @types/md5 @types/node @types/pg ts-node typescript nodemon

touch .env .env.example .gitignore .prettierrc tsconfig.json

sed -i '5 i\"scripts": {"start": "node ./build/index.js", "dev": "nodemon ./src/index.ts", "build": "rm -rf ./build && tsc"},' ./package.json

echo "DB_USERNAME = $1
DB_PASSWORD = $2
PORT = $3
SESSION_SECRET = $4
MONGODB_URL = $5" >> .env

echo "DB_USERNAME = your_username
DB_PASSWORD = your_password
PORT = your_port
SESSION_SECRET = your_secret 
MONGODB_URL = your_mongodb_url" >> .env.example

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

echo -e "/node_modules\n/build\n/.env" >> .gitignore

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

mkdir src   

cd src 

mkdir Configs Resolvers Entities Types Middlewares Models Utils Constants

touch index.ts

echo "require('reflect-metadata');
require('dotenv').config();
import express from 'express';
import { createConnection } from 'typeorm';
import Logger from './Configs/Logger';
import { ApolloServer } from 'apollo-server-express';
import { buildSchema } from 'type-graphql';
import { ApolloServerPluginLandingPageGraphQLPlayground } from 'apollo-server-core';
import MongoStore from 'connect-mongo';
import session from 'express-session';
import mongoose from 'mongoose';
import { Context } from './Types/Context';
import { COOKIES_NAME, __prod__ } from './Constants/';
import HelloResolver from './Resolvers/Hello';
import User from './Entities/User';
import AuthResolver from './Resolvers/Auth';

const main = async () => {
    await createConnection({
        type: 'postgres',
        database: '$6',
        username: process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        logging: true,
        synchronize: true,
        entities: [User],
    });

    const app = express();
    const PORT = process.env.PORT || 4000;

    const apolloServer = new ApolloServer({
        schema: await buildSchema({
            resolvers: [HelloResolver, AuthResolver],
        }),
        plugins: [ApolloServerPluginLandingPageGraphQLPlayground()],
        context: ({ req, res }): Context => ({ req, res }),
    });

    //session
    const mongoUrl = process.env.MONGODB_URL as string;
    await mongoose.connect(mongoUrl);

    Logger.success('MongoDB is connected');

    app.use(
        session({
            name: COOKIES_NAME,
            store: MongoStore.create({ mongoUrl }),
            cookie: {
                maxAge: 1000 * 60, //one hour
                httpOnly: true,
                secure: __prod__,
                sameSite: 'lax',
            },
            secret: process.env.SESSION_SECRET as string,
            saveUninitialized: false,
            resave: false,
        })
    );

    await apolloServer.start();

    apolloServer.applyMiddleware({ app, cors: false });

    app.listen(PORT, () =>
        Logger.success(\`Server is running on: http://localhost:\${PORT}\${apolloServer.graphqlPath}\`)
    );
};

main().catch((err) => console.log(err));" >> index.ts

cd Configs

touch Logger.ts

echo "import chalk from 'chalk';

export default class Logger {
    public static success(content: any): void {
        console.log(chalk.bgGreen.black(content));
    }
    public static error(content: any): void {
        console.log(chalk.bgRed.black(content));
    }
}" >> Logger.ts

cd ../Types

touch Context.ts

echo "import { Request, Response } from 'express';
import { Session, SessionData } from 'express-session';

export type Context = {
    req: Request & { session: Session & Partial<SessionData> & { userId?: number } };
    res: Response;
};" >> Context.ts

mkdir InputType Mutation

cd ../Constants

touch index.ts

echo "export const COOKIES_NAME = 'clothes_shop';
export const __prod__ = process.env.NODE_ENV === 'production';" >> index.ts

cd ../Resolvers

touch Hello.ts Auth.ts

echo "import { Query, Resolver } from \"type-graphql\";

@Resolver()
export default class HelloResolver{
    @Query(_return => String)
    hello(): string{
        return \"Hello Doba\";
    }
}" >> Hello.ts

echo "import md5 from \"md5\";
import { Arg, Mutation, Resolver } from \"type-graphql\";
import Logger from \"../Configs/Logger\";
import User from \"../Entities/User\";
import RegisterInput from \"../Types/InputType/RegisterInput\";
import UserMutationResponse from \"../Types/Mutation/UserMutationResponse\";
import { ValidateRegister } from \"../Utils/Validation\";

@Resolver()
export default class AuthResolver {
    //Register
    @Mutation((_return) => UserMutationResponse)
    async Register(
        @Arg('registerInput') registerInput: RegisterInput
    ): Promise<UserMutationResponse> {
        const { username, email, password } = registerInput;
        const validate = ValidateRegister(registerInput);

        if (validate !== null) {
            return {
                ...validate,
            };
        }

        try {
            const existingUser = await User.findOne({
                where: [{ username }, { email }],
            });

            if (existingUser) {
                return {
                    code: 400,
                    message: 'Duplicate username or email',
                    success: false,
                    errors: [
                        {
                            field: existingUser.username === username ? 'username' : 'email',
                            message: \`\${ existingUser.username === username ? 'Username' : 'Email'} already taken\`,
                        },
                    ],
                };
            }

            const hashPassword = md5(password);

            const newUser = User.create({
                ...registerInput,
                password: hashPassword,
            });

            return {
                code: 201,
                success: true,
                message: 'Register successfully',
                user: await User.save(newUser),
            };
        } catch (error: any) {
            Logger.error(error.message);

            return {
                code: 500,
                success: false,
                message: \`Interval server error \${error.message}\`,
            };
        }
    }
}" >> Auth.ts

cd ../Entities

touch User.ts

echo "import { Field, ID, ObjectType } from \"type-graphql\";
import { BaseEntity, Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from \"typeorm\";

@Entity()
@ObjectType()
export default class User extends BaseEntity{
    @PrimaryGeneratedColumn()
    @Field(_return => ID)
    id!: number;

    @Column()
    @Field()
    username!: string;

    @Column()
    @Field()
    email!: string;

    @Column()
    @Field()
    name!: string;

    @Column()
    @Field()
    password!: string;

    @CreateDateColumn({nullable: true})
    @Field({nullable: true})
    createdAt?: Date;

    @UpdateDateColumn({nullable: true})
    @Field({nullable: true})
    updatedAt?: Date;
}" >> User.ts

cd ../Types

touch FieldError.ts

echo "import { Field, ObjectType } from \"type-graphql\";

@ObjectType()
export default class FieldError{
    @Field()
    field!: string;

    @Field()
    message!: string;
}" >> FieldError.ts

cd InputType

touch RegisterInput.ts

echo "import { Field, InputType } from \"type-graphql\";

@InputType()
export default class RegisterInput{
    @Field()
    name!: string;

    @Field()
    email!: string;

    @Field()
    username!: string;

    @Field()
    password!: string;
}" >> RegisterInput.ts

cd ../Mutation

touch MutationResponse.ts UserMutationResponse.ts

echo "import { Field, InterfaceType } from 'type-graphql';
import FieldError from '../FieldError';

@InterfaceType()
export default abstract class MutationResponse {
    @Field()
    code!: number;

    @Field()
    success!: boolean;

    @Field()
    message!: string;

    @Field((_return) => [FieldError], { nullable: true })
    errors?: FieldError[];
}" >> MutationResponse.ts

echo "import { Field, ObjectType } from \"type-graphql\";
import User from \"../../Entities/User\";
import FieldError from \"../FieldError\";
import MutationResponse from \"./MutationResponse\";

@ObjectType({implements: MutationResponse})
export default class UserMutationResponse implements MutationResponse{
    code: number;
    success: boolean;
    message: string;
    errors?: FieldError[] | undefined;

    @Field({nullable: true})
    user?: User;
}" >> UserMutationResponse.ts

cd ../../Utils

touch Validation.ts

echo "import RegisterInput from '../Types/InputType/RegisterInput';
import UserMutationResponse from '../Types/Mutation/UserMutationResponse';

export const ValidateRegister = (registerInput: RegisterInput): UserMutationResponse | null => {
    const { username, email, password } = registerInput;

    //username
    if (username.length < 6){
        return {
            code: 400,
            success: false,
            message: 'Invalid username',
            errors: [{
                field: 'username',
                message: 'Username length must at least 6 characters'
            }]
        }
    }
    if (username.includes('@')){
        return {
            code: 400,
            success: false,
            message: 'Invalid username',
            errors: [{
                field: 'username',
                message: 'Username can not include @ symbol'
            }]
        }
    }
    
    //email
    if (!email.includes('@')){
        return {
            code: 400,
            success: false,
            message: 'Invalid email',
            errors: [{
                field: 'email',
                message: 'Email must include @ symbol'
            }]
        }
    }
    
    //password
    if (password.length < 6){
        return {
            code: 400,
            success: false,
            message: 'Invalid password',
            errors: [{
                field: 'password',
                message: 'Password length must at least 6 characters'
            }]
        }
    }

    return null;
};" >> Validation.ts

git add --all
git commit -m "First commit (Server)"
#!/usr/bin/env node
const inquirer = require("inquirer");
const cp = require("child_process");

(async () => {
    const { framework, PORT, MONGODB_URL } = await inquirer.prompt([
        {
            type: "list",
            message: "Pick a framework you'r using:",
            name: "framework",
            choices: ["GraphQL", "ExpressJS"],
        },
        {
            type: "input",
            name: "PORT",
        },
        {
            type: "input",
            name: "MONGODB_URL",
        },
    ]);

    switch (framework) {
        case "GraphQL":
            const { DB_USERNAME, DB_PASSWORD, database, SESSION_SECRET } =
                await inquirer.prompt([
                    {
                        type: "input",
                        name: "DB_USERNAME",
                    },
                    {
                        type: "input",
                        name: "DB_PASSWORD",
                    },
                    {
                        type: "input",
                        name: "database",
                    },
                    {
                        type: "input",
                        name: "SESSION_SECRET",
                    },
                ]);

            console.log("Waiting for installation...");
            cp.execSync(
                `sh ${__dirname}\\graphql-init.sh ${DB_USERNAME} ${DB_PASSWORD} ${PORT} ${SESSION_SECRET} ${MONGODB_URL} ${database}`
            );
            break;
        case "ExpressJS":
            console.log("Waiting for installation...");
            cp.execSync(
                `sh ${__dirname}\\expressjs-init.sh ${PORT} ${MONGODB_URL}`
            );
            break;
        default:
            console.log("Choose your option");
            break;
    }
})();

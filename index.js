#!/usr/bin/env node
const inquirer = require("inquirer");
const cp = require("child_process");

(async () => {
    const { framework } = await inquirer.prompt([
        {
            type: "list",
            message: "Pick a framework you'r using:",
            name: "framework",
            choices: ["GraphQL", "ExpressJS"],
        },
    ]);

    switch (framework) {
        case "GraphQL":
            cp.execSync("sh ./node_modules/doba-template/graphql-init.sh");
            break;
        case "ExpressJS":
            cp.execSync("sh ./node_modules/doba-template/expressjs-init.sh");
            break;
        default:
            console.log("Choose your option");
            break;
    }
})();

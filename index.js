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

  const { PORT } = await inquirer.prompt([
    {
      type: "input",
      name: "PORT",
    },
  ]);

  const { MONGODB_URL } = await inquirer.prompt([
    {
      type: "input",
      name: "MONGODB_URL",
    },
  ]);

  switch (framework) {
    case "GraphQL":
      const { DB_USERNAME } = await inquirer.prompt([
        {
          type: "input",
          name: "DB_USERNAME",
        },
      ]);
      const { DB_PASSWORD } = await inquirer.prompt([
        {
          type: "input",
          name: "DB_PASSWORD",
        },
      ]);
      const { SESSION_SECRET } = await inquirer.prompt([
        {
          type: "input",
          name: "SESSION_SECRET",
        },
      ]);
      cp.execSync(
        `sh ./node_modules/doba-template/graphql-init.sh ${DB_USERNAME} ${DB_PASSWORD} ${PORT} ${SESSION_SECRET} ${MONGODB_URL}`
      );
      break;
    case "ExpressJS":
      cp.execSync(
        `sh ./node_modules/doba-template/expressjs-init.sh ${PORT} ${MONGODB_URL}`
      );
      break;
    default:
      console.log("Choose your option");
      break;
  }
})();

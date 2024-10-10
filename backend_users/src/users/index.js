const express = require("express");
const router = express.Router();
const { UserController } = require("./controller");

module.exports.UserAPI = (app) => {
  router.post("/", UserController.verificacionLogin);

  app.use("/api/login", router);
};

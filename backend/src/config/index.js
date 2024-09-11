require("dotenv").config();

module.exports.Config = {
  port: process.env.PORT,
  user: process.env.USER,
  pass: process.env.PASS,
  db: process.env.DATABASE,
};

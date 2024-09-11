const { Pool } = require("pg");
const {Config}=require('../config');

// Configuración de la conexión a PostgreSQL
module.exports.DataBase = new Pool({
  host: "localhost",
  user: `${Config.user}`,
  password: `${Config.pass}`,
  database: `${Config.db}`,
  port: "5432",
});

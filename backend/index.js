const express = require("express");
const debug = require("debug")("app: module-main");
const cors = require("cors");
const app = express();
const { Config } = require("./src/config");
const {AlumnoAPI}=require('./src/alumnos');

// Admisión de datos JSON y comunicación entre puertos
app.use(express.json());
app.use(cors());

// APIS
AlumnoAPI(app)

// Levantamos el servidor
app.listen(Config.port, "0.0.0.0", () => {
  debug(`Servidor escuchando en el puerto http://0.0.0.0:${Config.port}`);
});

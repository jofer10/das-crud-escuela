const express = require("express");
const router = express.Router();
const { AlumnosController } = require("./controller");

module.exports.AlumnoAPI = (app) => {
  router
  .post("/", AlumnosController.getAlumnos)
  .post("/add", AlumnosController.createAlumno)
  .post("/upd", AlumnosController.updateAlumno)
  .delete("/:id", AlumnosController.deleteAlumno);

  app.use("/api/alumnos", router);
};

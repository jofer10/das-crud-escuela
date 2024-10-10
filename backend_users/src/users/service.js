const debug = require("debug")("app: module-users-service");
const { DataBase } = require("../database");
const bcrypt = require('bcrypt');

const loginValidacion = async (payload) => {
  try {
    const { rows } = await DataBase.query(
      "select * from ufn_login_validacion_correo($1)",
      [payload.correo]
    );

    // Verficicar que la clave de la base coincida con la clave que manda el usuario
    if (await bcrypt.compare(payload.password, rows[0].usu_key_access)){
        const query = `select * from ufn_login_validacion_correo('${payload.correo}')`;
        return [rows, query];
    }

    return null;
  } catch (error) {
    debug(error);
    throw error;
  }
};

module.exports.UserService = {
  loginValidacion,
};
